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

		// Let the distinguisher config know how many summarizers
		// we've decided to use.
		distinguisherConfig.countSummarizers(vec);

		// Actually summarize the reports.
		vec.forEach({ x: handleSummary(x, t) });
	}

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

	querySummarizerForReport(report) {
		local r;

		r = new Vector();

		if(report == nil)
			return(r);

		forEachSummarizerFor(report.dobj_, function(s) {
			if(s.acceptReport(report))
				r.append(s);
		});

		return(r);
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

		// Let the distinguisher config know how many distinguishers
		// we've come up with
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

		if(!summarizer.checkData(data))
			return(nil);

		// Create a SummaryData instance from the reports
		d = new ReportSummaryData(data.reports);

		// Create the CommandReportSummary from the summarizer's
		// output
		if(summarizer.noDistinguisher == true)
			distinguisherConfig.noDistinguisher = true;
		r = createSummaryReport(d, summarizer._summarize(d));

		r.isFailure = summarizer.isFailure;
		r.dobj_ = nil;

		// Mark the summary report as belonging to the same group
		// as the first parent report
		r.iter_ = data.reports[1].iter_;

		// Replace the reports with the summary
		replaceReports(data.reports, r);

		return(r);
	}

	// Create a single implicit action summary report.
	// First arg is the summarizer (i.e. a ReportSummary instance).
	// Second arg is a DistinguisherData instance.
	// Third arg is the transcript.
	_handleImplicit(summarizer, data, t) {
		local d, idx, r, txt;

		//if(!summarizer.checkData(data))
			//return;

		// Create a SummaryData instance from the reports
		d = new ReportSummaryData(data.reports);

		// Get the summary text
		txt = summarizer._summarize(d);

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

		// Remove the reports we're summarizing
		removeReports(data.reports, t);

		// Insert the updated implicit announcement at the location
		// where our first report was
		insertReport(r, idx, t);

		// See if we want to re-insert any non-default implicit
		// action reports
		_handleImplicitRejected(summarizer, r, data, t);
	}

	// See if we have any non-default implicit action reports and
	// if so, we insert them back into the transcript right after
	// our implicit action summary.  Then we check to see if
	// the non-default reports have an object-specific summarizer.
	// And if they have one, use it.
	_handleImplicitRejected(summarizer, report, data, t) {
		local d, idx, r, s, v;

		// Build a vector of all of the reports the summarizer
		// didn't want to touch.  Since we're here in the middle
		// of handling an implicit action summary, this means
		// these are implicit action reports that are "non-default";
		// they have a custom action message.
		v = new Vector();
		data.reports.forEach(function(o) {
			if(o._rejectedBySummarizer == summarizer)
				v.append(o);
		});

		// If we don't have any rejected reports, we have nothing
		// else to do
		if(v.length < 1)
			return;

		// "report" is the implicit action summary, so
		// we want to start inserting rejected action
		// reports right after it
		idx = t.reports_.indexOf(report);

		// Now we go through the rejected reports and re-insert
		// them into the transcript.  We also get the summarizer
		// (we only check for one, maybe a misfeature---are there
		// cases where a single implicit action can involve additional
		// nested actions?)
		s = nil;
		v.forEach(function(o) {

			// Re-insert the rejected report into the transcript
			idx += 1;
			insertReport(o, idx);

			// If we don't already have a summarizer for the
			// rejected reports, check for one
			if(s == nil) {
				s = getSummarizerFor(o, function(rs) {
					// CONFUSING:  Because ImplicitAction
					//	is a subclass of ActionSummary
					//	we don't have to explicitly
					//	check for it
					return(!rs.ofKind(ActionSummary));
				}, true);
			}
		});

		// No summarizer, no summary
		if(s == nil)
			return;

		// Create a DistinguisherData instance containing the
		// rejected reports
		d = new DistinguisherData(nil);
		d.reports.appendAll(v);

		// Have the summarizer summarize the rejected reports
		if((r = _handleSummary(s, d, t)) != nil) {
			// Add a report separator after the re-inserted
			// rejected reports.
			idx = t.reports_.indexOf(r);
			insertReport(new GroupSeparatorMessage(r), idx + 1);
		}
	}

	getSummarizerFor(report, fn?, ignoreImplicit?) {
		local i, m, s;

		if(report == nil)
			return(nil);
		if(report.dobj_ && ((m = report.dobj_.reportManager) != nil)) {
			if((s = m.getSummarizerFor(report, fn, ignoreImplicit)) != nil)
				return(s);
		}
		for(i = 1; i <= _reportManagers.length; i++) {
			m = _reportManagers[i];
			if((s = m.getSummarizerFor(report, fn, ignoreImplicit)) != nil)
				return(s);
		}

		return(nil);
	}
/*
	getReportsRejectedBy(summarizer) {
		local v;

		v = new Vector();
		forEachReport(function(o) {
			if(o._rejectedBySummarizer == summarizer)
				v.append(o);
		});

		return(v);
	}

	summarizeNonDefaultImplicit(summarizer, t) {
		local lst, s;

		if((summarizer == nil) || (summarizer.nonDefaultReports == nil))
			return;

		lst = new Vector();
		summarizer.forEachNonDefaultReport(function(o) {
			lst.appendAll(querySummarizersForReport(o));
		});
		lst = lst.subset({ x: !x.ofKind(ImplicitSummary) });
		summarizer.forEachNonDefaultReport(function(o) {
			s = assignSummarizer(o, lst);
		});

		if(s == nil)
			return;

		_handleSummary(s, summarizer.nonDefaultReports, t);
	}
*/

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

	forEachReportManager(fn) {
		if(_reportManagers == nil)
			return;
		_reportManagers.forEach({ x: (fn)(x) });
	}

	forEachSummarizerFor(obj, fn) {
		if(obj == nil)
			return;
		if(obj.reportManager)
			obj.reportManager.forEachSummary({ x: (fn)(x) });
		forEachReportManager({ x: x.forEachSummary({ s: (fn)(s) }) });
	}
;
