#charset "us-ascii"
//
// transcriptToolsReportManager.t
//
//	TranscriptTool class and related stuff for handling report managers.
//
//
#include <adv3.h>
#include <en_us.h>

#include "transcriptTools.h"

/*
// Data structure for holding the reports for a specific summarizer.
// Normal flow is to go through the transcript and see which reports
// want to be handled by which summarizers.  The result of that
// process is a vector of instances of SummarizerData.
class SummarizerData: object
	// The summarizer, i.e. an instance of ReportSummary
	summarizer = nil

	// The reports to be passed to the summarizer above
	reports = perInstance(new Vector())

	construct(s) { summarizer = s; }
;

// Data structure for holding the reports for a specific distinguisher
// announcement
// In the normal flow of processing the reports for each summarizer (as
// organized into SummarizerData instances, above) are iterated through,
// determining what object distinguisher announcement, if any, is needed
// for disambiguation in the report.  In this case the distinguisher
// is the noun phrase before the colon in the output.
// We also use DistinguisherData to aggregate implicit reports, in that
// case using their action as "distinguisher".
class DistinguisherData: object
	// The distinguisher text
	distinguisher = nil

	// Vector of reports sharing the distinguisher above
	reports = perInstance(new Vector())

	construct(d) { distinguisher = d; }
;
*/

/*
// Data structure for handling the deliberations about whether or not
// to include distinguisher announcements with report summaries.
class DistinguisherConfig: object
	distinguishers = 0
	summarizers = 0
	summarizedDobjCount = 0
	transcriptDobjCount = 0
	noDistinguisher = nil

	setSummarizerVector(lst) {
		local v;

		if(lst == nil)
			return;

		v = new Vector(lst.length);
		lst.forEach(function(o) {
			o.reports.forEach({ x: v.appendUnique(x.dobj_) });
			if(!o.summarizer.isImplicit)
				summarizers += 1;
		});

		summarizedDobjCount = v.length;

		if(gAction && gAction.dobjList_)
			transcriptDobjCount = gAction.dobjList_.length;
	}

	countDistinguishers(lst) {
		distinguishers = lst.length;
	}

	check() {
		if(((distinguishers > 1) || (summarizers > 1)
			|| (summarizedDobjCount != transcriptDobjCount)))
			return(true);
		return(!noDistinguisher);
	}

	clear() {
		distinguishers = 0;
		summarizers = 0;
		summarizedDobjCount = 0;
		transcriptDobjCount = 0;
		noDistinguisher = nil;
	}
;
*/

class TranscriptReportManager: TranscriptTool
	toolPriority = 500

	// List of report manager classes.  At preinit if we don't
	// already have an instance of any of these, we'll add one
	defaultReportManagers = nil

	distinguisherConfig = perInstance(new DistinguisherConfig)

	// List of all of our "personal" report managers.  This is NOT
	// all the report managers we might use.  This is just the
	// list of ones that we made for our own use.
	_reportManagers = nil

	// Last game turn we ran on
	_timestamp = nil

	// Boolean flag indicating whether or not to prepend object
	// announcements to reports
	//_distinguisherFlag = nil

	// Returns the report manager, if any, in our personal list
	// that matches the given class.
	// This doesn't check ALL report managers, just ones we created
	// for ourselves.
	getReportManager(cls) {
		local i;

		if(_reportManagers == nil)
			return(nil);

		for(i = 1; i <= _reportManagers.length; i++) {
			if(_reportManagers[i].ofKind(cls))
				return(_reportManagers[i]);
		}

		return(nil);
	}

	// Preinit method.
	initializeTranscriptTool() {
		inherited();
		addDefaultReportManagers();
	}

	// Add a report manager to our list.
	// IMPORTANT:  We DO NOT do this for every report manager we
	// 	use.  This is ONLY for ones we've created for our own
	//	use.
	addReportManager(obj) {
		if((obj == nil) || !obj.ofKind(ReportManager))
			return;

		if(_reportManagers == nil)
			_reportManagers = new Vector();

		obj.parentTools = self;

		_reportManagers.append(obj);
	}

	// Make sure we have instances of all the report manager types
	// in our default list
	addDefaultReportManagers() {
		local obj;

		if(defaultReportManagers == nil)
			return;

		if(!defaultReportManagers.ofKind(Collection))
			defaultReportManagers = [ defaultReportManagers ];

		defaultReportManagers.forEach(function(o) {
			if(getReportManager(o))
				return;
			obj = o.createInstance();
			obj.location = self;
			obj.initializeReportManager();
			addReportManager(obj);
		});
	}

	// Getter and setter for the distinguisher flag
	//getDistinguisherFlag() { return(_distinguisherFlag == true); }
	//setDistinguisherFlag() { _distinguisherFlag = true; }
	getDistinguisherFlag() { return(distinguisherConfig.check()); }

	// Main lifecycle method, called by our TranscriptTool parent
	// during afterActionMain()
	run() {
		local t, vec;

		// Use the turn number to make sure we're not running
		// multiple times in a single turn.
		if(_timestamp == gTurn)
			return;
		_timestamp = gTurn;

		// Reset the distinguisher flag.
		//_distinguisherFlag = nil;
		distinguisherConfig.clear();

		// If we can't get the granscript for some reason, die
		// out of shame
		if((t = getTranscript()) == nil)
			return;

		// Get a list of all the reports we want to summarize,
		// grouped by the summarizer that wants to summarize them.
		vec = assignSummarizers();

		// Got nuthin, got nuthin to do
		if(vec.length < 1)
			return;

		// If we have more than one bunch of reports to summarize,
		// we'll use distinguishers to distinguish them.
		distinguisherConfig.setSummarizerVector(vec);

		// See if we've got as many summaries as we have objects.
		// This is for the specific case where all of our reports
		// end up in a single summary.  We don't have to explicitly
		// check for that, because if we're summarizing all reports
		// but splitting them into multiple summaries we'll pick
		// that up elsewhere.
/*
		if(getTotalDobjCount() != getSummarizedDobjCount(vec)) {
			setDistinguisherFlag();
		}
*/

		// Actually summarize the reports.
		vec.forEach({ x: handleSummary(x, t) });
	}

/*
	// Total number of direct objects mentioned in the current
	// action
	getTotalDobjCount() {
		return((gAction && gAction.dobjList_)
			? gAction.dobjList_.length : 0);
	}

	// Get the number of reports we're summarizing.
	getSummarizedDobjCount(vec) {
		local v;

		v = new Vector(vec.length);
		vec.forEach(function(o) {
			o.reports.forEach({ x: v.appendUnique(x.dobj_) });
		});
		return(v.length);
	}
*/

	// Figure out if anyone wants to summarize this report
	assignSummarizer(report, lst?) {
		local r;

		if((r = report.getReportSummarizer(lst)) != nil)
			return(r);

		r = getReportSummarizer(report, lst);

		return(r);
	}

	// Get the summarizer for the given report
	getReportSummarizer(report, lst) {
		local i, r;

		if(_reportManagers == nil)
			return(nil);

		for(i = 1; i <= _reportManagers.length; i++) {
			if((r = _reportManagers[i].getReportSummarizer(report,
				lst)) != nil)
				return(r);
		}

		return(nil);
	}

	// Go through all of the reports we're handling and figure out
	// which summarizer, if any, wants to handle each of them.
	// Returns a vector of SummarizerData instances
	assignSummarizers() {
		local lst, o, s, vec;

		vec = new Vector(8);

/*
		// Go through the list of reports, checking to see if
		// there's a summarizer that wants to summarize it.
		forEachReport(function(report) {
			// No summarizer, nothing to do
			if((s = assignSummarizer(report)) == nil)
				return;

			// If we haven't seen this summarizer before,
			// create a new summary data object for it
			if((o = vec.valWhich({
				x: x.summarizer == s
			})) == nil) {
				vec.append(new SummarizerData(s));
				o = vec[vec.length];
			}

			// Add this report to the reports for this summarizer
			o.reports.append(report);
		});
*/
		// Go through each report group, generating a list of
		// candidate summarizers for the reports.
		forEachReportGroup(function(grp) {
			if((lst = querySummarizersForGroup(grp)) == nil)
				return;

			// Now go through each report in the group, and
			// get a summarizer for each.
			grp.forEachReport(function(report) {
				if((s = assignSummarizer(report, lst))
					== nil)
					return;

				// If we haven't seen this summarizer before,
				// create a new summary data object for it
				if((o = vec.valWhich({
					x: x.summarizer == s
				})) == nil) {
					vec.append(new SummarizerData(s));
					o = vec[vec.length];
				}
				o.reports.append(report);
			});
		});

		return(vec);
	}

	// Get a list of candidate summarizers for this report group.
	// This is for decisions that involve multiple reports.  That
	// usually happens when a specific action might produce multiple
	// reports--like a default report and a full report--and we just
	// want to summarize if there's ONLY a default report.
	querySummarizersForGroup(grp) {
		local i, r;

		r = new Vector();

		// First go through the reports.  If they have direct
		// objects and the direct objects have report managers,
		// see if they want to accept the group.  This is for
		// object-specific report managers.
		grp.forEachReport(function(o) {
			if((o.dobj_ == nil) || (o.dobj_.reportManager == nil))
				return;
			o.dobj_.reportManager.forEachSummary(function(s) {
				if(s.acceptGroup(grp) == true)
					r.append(s);
			});
		});

		// Now we go through "our" report managers and see if any
		// of them want to accept the group.  This is for the
		// "built-in" action-based summaries.
		for(i = 1; i <= _reportManagers.length; i++) {
			_reportManagers[i].forEachSummary(function(s) {
				if(s.acceptGroup(grp) == true)
					r.append(s);
			});
		}

		return(r);
	}

	// Summarize all the reports being handled by a specific summarizer.
	// First arg is a SummarizerData instance, second is the transcript
	// we're working on
	handleSummary(data, t) {
		local imp, vec;

		vec = new Vector();	// normal reports
		imp = new Vector();	// implicit reports

		// Go through all the reports for this summarizer,
		// populating the implicit and non-implicit vectors
		// with DistinguisherData instances
		data.reports.forEach(function(report) {
			if(report.isActionImplicit())
				_groupReportsByAction(report, imp);
			else if(data.summarizer.noDistinguisher == true)
				_groupReportsByAction(report, vec);
			else
				_groupReportsByDistinguisher(report, vec);

		});

		// If we have more than one distinguisher's worth of
		// reports, we (obviously) want to use distinguisher
		// announcements
/*
		if(vec.length > 1) {
			setDistinguisherFlag();
		}
*/
		distinguisherConfig.countDistinguishers(vec);

		imp.forEach({ x: _handleImplicit(data.summarizer, x, t) });
		vec.forEach({ x: _handleSummary(data.summarizer, x, t) });
	}

	// Group implicit action reports by their action.
	// First arg is a report, second is a vector of DistinguisherData
	// instances
	_groupReportsByAction(report, vec) {
		local o;

		// If we haven't seen this report's action before, create
		// a distinguisher data object for it and add it to the
		// vector
		if((o = vec.valWhich({ x: x.distinguisher == vec.action_ }))
			== nil) {
			vec.append(new DistinguisherData(vec.action_));
			o = vec[vec.length];
		}

		// Add this report to the relevant distinguisher data object
		o.reports.append(report);
	}

	// Group reports by their distinguisher announcement text.
	// First arg is a report, second is a vector of DistinguisherData
	// instances
	_groupReportsByDistinguisher(report, vec) {
		local dist, o;

		// Get the distinguisher for this report
		dist = getReportDistinguisher(report.dobj_, 1);

		// If we haven't seen this distinguisher before,
		// create a new distinguisher data object for
		// it
		if((o = vec.valWhich({ x: x.distinguisher == dist })) == nil) {
			vec.append(new DistinguisherData(dist));
			o = vec[vec.length];
		}

		// Add this report to the reports for this
		// distinguisher
		o.reports.append(report);
	}

	// Actually create a single non-implicit summary report.
	// First arg is the summarizer (i.e. a ReportSummary instance).
	// Second arg is a DistinguisherData instance.
	// Third arg is the transcript.
	_handleSummary(summarizer, data, t) {
		local d, r;

		// Create a SummaryData instance from the reports
		d = new ReportSummaryData(data.reports);

		// Create the CommandReportSummary from the summarizer's
		// output
		//r = createSummaryReport(d, summarizer.summarize(d),
			//(summarizer.noDistinguisher ? true : nil));
		if(summarizer.noDistinguisher == true)
			distinguisherConfig.noDistinguisher = true;
		r = createSummaryReport(d, summarizer.summarize(d));

		r.isFailure = summarizer.isFailure;
		r.dobj_ = nil;

		// Mark the summary report as belonging to the same group
		// as the first parent report
		r.iter_ = data.reports[1].iter_;

		// Replace the reports with the summary
		replaceReports(data.reports, r);
	}

	// Create a single implicit action summary report.
	// First arg is the summarizer (i.e. a ReportSummary instance).
	// Second arg is a DistinguisherData instance.
	// Third arg is the transcript.
	_handleImplicit(summarizer, data, t) {
		local d, idx, r, txt;

		// Create a SummaryData instance from the reports
		d = new ReportSummaryData(data.reports);

		// Get the summary text
		txt = summarizer.summarize(d);

		// Identify the first report we just summarized that's
		// an implicit action announcement
		r = data.reports.valWhich({
			x: x.ofKind(ImplicitActionAnnouncement)
		});

		// Get the index in the transcript of our first report
		idx = t.reports_.indexOf(data.reports[1]);

		// Update the chosen implicit announcement to have the
		// summary text
		r.messageText_
			= '<.p0>\n<.assume><<toString(txt)>><./assume>\n';
		r.messageProp_ = nil;

		// Remove our reports from the transcript
		data.reports.forEach({ x: t.reports_.removeElement(x) });

		// Insert the updated implicit announcement at the location
		// where our first report was
		t.reports_.insertAt(idx, r);
	}

	// Create the summary report object.
	// First arg is the summary data.
	// Second arg is the summary text.
	// Optional third arg is the distinguisher announcement.  If
	// not given it will be computed if needed.
	createSummaryReport(data, msg, noDist?) {
		local dist, txt;

		txt = new StringBuffer();

		if(!noDist && (getDistinguisherFlag() == true)) {
			dist = getReportDistinguisher(data.dobj,
				data.objs.length);
			txt.append('<./p0>\n<.announceObj>');
			txt.append(dist);
			txt.append(':<./announceObj> <.p0>');
		}
		txt.append(msg);

		return(new CommandReportSummary(toString(txt)));
	}

	// Figure out what distinguisher announcement to use.
	getReportDistinguisher(obj, n) {
		if(obj == nil)
			return(nil);

		if(gameMain.useDistinguishersInAnnouncements == nil)
			return(nil);

		if(obj.reportManager
			&& obj.reportManager.reportManagerAnnounceText)
			return(obj.reportManager.reportManagerAnnounceText);

		return(obj.getBestDistinguisher(gAction
			.getResolvedObjList(DirectObject))
			.reportName(obj, n));
	}
;
