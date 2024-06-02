#charset "us-ascii"
//
// transcriptToolsReportManager.t
//
//
#include <adv3.h>
#include <en_us.h>

#include "transcriptTools.h"

// Data structure for holding the reports for a specific summarizer.
// Normal flow is to go through the transcript and see which reports
// want to be handled by which summarizers.  The result of that
// process is a vector of instances of SummarizerData.
class SummarizerData: object
	summarizer = nil
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
	distinguisher = nil
	reports = perInstance(new Vector())
	construct(d) { distinguisher = d; }
;

class TranscriptReportManager: TranscriptTool
	toolPriority = 500

	// List of report manager classes.  At preinit if we don't
	// already have an instance of any of these, we'll add one
	defaultReportManagers = nil
/*
	defaultReportManagers = static [
		GeneralReportManager,
		SelfReportManager
	]
*/

	// List of all of our "personal" report managers.  This is NOT
	// all the report managers we might use.  This is just the
	// list of ones that we made for our own use.
	_reportManagers = nil

	// Last game turn we ran on
	_timestamp = nil

	// Boolean flag indicating whether or not to prepend object
	// announcements to reports
	_distinguisherFlag = nil

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
		if(_reportManagers == nil)
			_reportManagers = new Vector();
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
	getDistinguisherFlag() { return(_distinguisherFlag == true); }
	setDistinguisherFlag() { _distinguisherFlag = true; }

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
		_distinguisherFlag = nil;

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
		if(vec.length > 1)
			setDistinguisherFlag();

		// See if we've got as many summaries as we have objects.
		// This is for the specific case where all of our reports
		// end up in a single summary.  We don't have to explicitly
		// check for that, because if we're summarizing all reports
		// but splitting them into multiple summaries we'll pick
		// that up elsewhere.
		if(getTotalDobjCount() != getSummarizedDobjCount(vec))
			setDistinguisherFlag();

		// Actually summarize the reports.
		vec.forEach({ x: handleSummary(x, t) });
	}

	// Total number of direct objects mentioned in the current
	// action
	getTotalDobjCount() {
		return((gAction && gAction.dobjList_)
			? gAction.dobjList_.length : 0);
	}

	// Get the number of reports we're summarizing.
	getSummarizedDobjCount(vec) {
		local n;

		n = 0;
		vec.forEach({ x: n += x.reports.length });
		return(n);
	}

	// Figure out if anyone wants to summarize this report
	assignSummarizer(report) {
		local r;

		if((r = report.getReportSummarizer()) != nil)
			return(r);

		r = getReportSummarizer(report);

		return(r);
	}

	getReportSummarizer(report) {
		local i, r;

		if(_reportManagers == nil)
			return(nil);

		for(i = 1; i <= _reportManagers.length; i++) {
			if((r = _reportManagers[i].getReportSummarizer(report))
				!= nil)
				return(r);
		}

		return(nil);
	}

	assignSummarizers() {
		local o, s, vec;

		vec = new Vector(8);

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

		return(vec);
	}

	// First arg is a SummarizerData instance, second is the transcript
	// we're working on
	handleSummary(data, t) {
		local imp, vec;

		vec = new Vector();
		imp = new Vector();

		// Go through all the reports for this summarizer
		data.reports.forEach(function(report) {
			if(report.isActionImplicit())
				_handleSummaryImplicit(report, imp);
			else
				_handleSummaryNonImplicit(report, vec);

		});

		// If we have more than one distinguisher's worth of
		// reports, we (obviously) want to use them
		if(vec.length > 1)
			setDistinguisherFlag();

		imp.forEach({ x: _handleImplicit(data.summarizer, x, t) });
		vec.forEach({ x: _handleSummary(data.summarizer, x, t) });
	}

	_handleSummaryImplicit(report, vec) {
		local o;

		if((o = vec.valWhich({ x: x.distinguisher == vec.action_ }))
			== nil) {
			vec.append(new DistinguisherData(vec.action_));
			o = vec[vec.length];
		}
		o.reports.append(report);
	}

	_handleSummaryNonImplicit(report, vec) {
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

	_handleSummary(summarizer, data, t) {
		local d, r;

		d = new ReportSummaryData(data.reports);
		r = createSummaryReport(d, summarizer.summarize(d));
		r.iter_ = data.reports[1].iter_;
		replaceReports(data.reports, r);
	}

	_handleImplicit(summarizer, data, t) {
		local d, idx, r, txt;

		d = new ReportSummaryData(data.reports);
		txt = summarizer.summarize(d);
		r = data.reports.valWhich({
			x: x.ofKind(ImplicitActionAnnouncement)
		});
		idx = t.reports_.indexOf(data.reports[1]);
		r.messageText_
			= '<.p0>\n<.assume><<toString(txt)>><./assume>\n';
		r.messageProp_ = nil;

		_removeReports(data.reports, t);

		t.reports_.insertAt(idx, r);
	}

	_removeReports(vec, t?) {
		vec.forEach({ x: t.reports_.removeElement(x) });
	}

	// Create the summary report object.
	// First arg is the summary data.
	// Second arg is the summary text.
	// Optional third arg is the distinguisher announcement.  If
	// not given it will be computed if needed.
	createSummaryReport(data, msg, dist?) {
		local txt;

		txt = new StringBuffer();

		if(getDistinguisherFlag() == true) {
			if(dist == nil)
				dist = getReportDistinguisher(data.dobj,
					data.vec.length);
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

		if(obj.reportManager
			&& obj.reportManager.reportManagerAnnounceText)
			return(obj.reportManager.reportManagerAnnounceText);

		return(obj.getBestDistinguisher(gAction
			.getResolvedObjList(DirectObject))
			.reportName(obj, n));
	}
;
