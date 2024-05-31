#charset "us-ascii"
//
// reportManager.t
//
//
#include <adv3.h>
#include <en_us.h>

#include "transcriptTools.h"

// The report manager object.
class ReportManager: TranscriptToolsWidget
	// What kind of object we're a manager for
	reportManagerFor = nil

	// Minimum number of reports needed to summarize.
	// If an action doesn't produce at least this many, we won't
	// do anything.
	minSummaryLength = 2

	// Announcement text for actions where there's a mixture of
	// summarized and non-summarized reports.  For example, if
	// we have a pebble and three balls and we're summarizing the
	// balls but not the pebble, we'll get something like:
	//
	//	>X ALL
	//	pebble: A small, round pebble.
	//	foo: It's a red ball, a blue ball, and a green ball.
	//
	// This controls what text is used for "foo" in the example above.
	// If nil, then no announcement text will be used (and the summary
	// will just be listed in a line by itself).
	reportManagerAnnounceText = nil

	// An optional list of ReportSummary classes to add to the report
	// manager.
	// Each summary handles a kind of Action, so if we have a list
	// default summaries we go through the list of summaries already
	// declared on the report manager and add a default for any
	// Action that isn't already handled.
	reportManagerDefaultSummaries = nil

	// The TranscriptTools we're part of
	parentTools = nil

	// List of our summary objects.
	_reportManagerSummaries = perInstance(new Vector())

	// Flag to indicate whether or not we need object distinguisher
	// announcements.
	_distinguisherFlag = nil

	// Preinit method.
	initializeReportManager() {
		initializeReportManagerFor();
		initializeReportManagerDefaultSummaries();
	}

	// Go through all the objects we're the report manager for and
	// make sure they know about us.
	initializeReportManagerFor() {
		if(reportManagerFor == nil) {
			reportManagerFor = [];
			return;
		}

		if(!reportManagerFor.ofKind(Collection))
			reportManagerFor = [ reportManagerFor ];

		reportManagerFor.forEach(function(cls) {
			forEachInstance(cls, function(o) {
				o.reportManager = self;
			});
		});
	}

	// Check to see if there are any default summaries that we don't
	// already have copies of.
	initializeReportManagerDefaultSummaries() {
		local l;

		// No default summaries, nothing to do.
		if(reportManagerDefaultSummaries == nil)
			return;

		// Make sure the list of defaults is list-ish.
		if(!reportManagerDefaultSummaries.ofKind(Collection))
			reportManagerDefaultSummaries
				= [ reportManagerDefaultSummaries ];

		// This will hold the summaries we need to add.
		l = new Vector(reportManagerDefaultSummaries.length);

		// Go through the list of defaults, checking to see
		// if we already have a summary for its action.
		reportManagerDefaultSummaries.forEach(function(o) {
			// If we already have a summary for this
			// action, bail.
			if(getSummaryForAction(o.action))
				return;

			// Remember that we need to add this default.
			l.appendUnique(o);
		});

		// Go through our list of defaults we don't have,
		// adding them.
		l.forEach(function(o) {
			addReportManagerSummary(o.createInstance());
		});
	}

	// Returns the summary for the given action, if we have one.
	getSummaryForAction(act) {
		local i;

		for(i = 1; i <= _reportManagerSummaries.length; i++) {
			if(_reportManagerSummaries[i].matchAction(act))
				return(_reportManagerSummaries[i]);
		}

		return(nil);
	}

	// Add a summary to our list.
	addReportManagerSummary(obj) {
		// Make sure it's valid.
		if((obj == nil) || !obj.ofKind(ReportSummary))
			return(nil);

		// Add it.
		_reportManagerSummaries.appendUnique(obj);

		// Have it remember us.
		obj.reportManager = self;

		return(true);
	}

	forEachSummary(fn) {  _reportManagerSummaries.forEach({ x: fn(x) }); }

	getDistinguisherFlag() {
		return(parentTools ? parentTools._distinguisherFlag == true
			: nil);
	}

	getReportSummarizer(report) {
		local i;

		if(!matchReportDobj(report.dobj_))
			return(nil);

		for(i = 1; i <= _reportManagerSummaries.length; i++) {
			if(_reportManagerSummaries[i].isImplicit == true)
				continue;
			if(_reportManagerSummaries[i].acceptReport(report))
				return(_reportManagerSummaries[i]);
		}

		return(nil);
	}

	matchReportDobj(obj) {
		local i;

		if(obj == nil)
			return(nil);

		for(i = 1; i <= reportManagerFor.length; i++) {
			if(obj.ofKind(reportManagerFor[i]))
				return(true);
		}

		return(nil);
	}

	matchReportAction(act) {
		local i;

		for(i = 1; i <= _reportManagerSummaries.length; i++) {
			if(_reportManagerSummaries[i].matchAction(act) == true)
				return(true);
		}

		return(nil);
	}

	matchReportFailure(report) {
		local i;

		for(i = 1; i <= _reportManagerSummaries.length; i++) {
			if(_reportManagerSummaries[i].isFailure
				== report.isFailure)
				return(true);
		}

		return(nil);
	}

	// Wrapper for the main checkReport() method.
	// This is where we look at a report and decide whether or not
	// we want to summarize it.
	_checkReport(report) {
		// Make sure the report is part of the action.
		if(report.action_ != gAction)
			return(nil);

		if(report.ofKind(CommandReportSummary))
			return(nil);

		// See if the report involves a kind of object we're
		// the report manager for.
		if(!matchReportDobj(report.dobj_))
			return(nil);

		// See if we have a summary that matches the action AND
		// failure status of the report.
		if(!matchReportAction(report.action_))
			return(nil);

		if(!matchReportFailure(report))
			return(nil);

		// Call the "real" method.
		if(checkReport(report) != true)
			return(nil);

		return(true);
	}

	// Decide whether or not we're going to summarize the given report.
	// To be overwritten by instances.
	checkReport(report) { return(true); }

	setDistinguisherFlag() {}

	// Basic distinguisher checks.
	_checkDistinguishers() {
		// If all the reports for the current action aren't being
		// summarized then we need to add object distinguishers.
		if(totalReportCount() != summarizedReportCount())
			setDistinguisherFlag();

		if(checkDistinguishers() == true)
			setDistinguisherFlag();
	}

	// For instances' bespoke distinguisher checks.
	// Should return true if the distinguisher flag should be set,
	// nil otherwise.
	checkDistinguishers() { return(nil); }

/*
	// Handle summarizing the reports passed to us in the vector.
	summarizeReports(vec) {
		local d, txt, s;

		// Create a string buffer to hold the summary.
		txt = new StringBuffer();

		s = vec[1].reportSummarizer;
		d = new ReportSummaryData(vec);
		tweakReportSummaryData(d);
		formatReport(vec, s._summarize(d), txt);

		return(toString(txt));
	}

	// General method to adjust the data object that will be used
	// for a summary.
	tweakReportSummaryData(data) {
		if((data == nil) || !data.ofKind(ReportSummaryData))
			return;

		if((data.dobj = getReportDobj(data)) != nil)
			data.dobj._reportCount = data.count;
	}

	// Basic dobj selecting method.  This assumes that the objects
	// are equivalent and so any one can be used.  Designed to
	// be overwritten by instances if something more elaborate
	// is needed (like using an object that's not even in the
	// reports).
	getReportDobj(data) {
		if((data.objs == nil) || (data.objs.length < 1))
			return(nil);

		return(data.objs[1]);
	}
*/

	// Report sorter.
	// We accept an unsorted vector of reports, and we return a
	// a vector of vectors, where each element is a vector of reports
	// to summarize together.
	sortReports(vec) {
		local dist, idx, l, vv;

		l = new Vector(vec.length);
		vv = new Vector(8);

		vec.forEach(function(o) {
			dist = getReportDistinguisher(o.dobj_, 1);

			if((idx = l.indexOf(dist)) == nil) {
				l.appendUnique(dist);
				vv.append(new Vector());
				idx = l.length;
			}

			vv[idx].append(o);
		});

		if(vv.length > 1)
			setDistinguisherFlag();

		return(vv);
	}

	formatReport(vec, summary, txt) {
		if(getDistinguisherFlag() == true) {
			txt.append('<./p0>\n<.announceObj>');
			txt.append(getReportDistinguisher(vec[1].dobj_,
				vec.length));
			txt.append(':<./announceObj> <.p0>');
		}
		txt.append(summary);
	}

	getReportDistinguisher(obj, n) {
		if(reportManagerAnnounceText)
			return(reportManagerAnnounceText);
		return(obj.getBestDistinguisher(
			gAction.getResolvedObjList(DirectObject))
			.reportName(obj, n));
	}

	// Returns the total number of reports for the current action
	// (including ones we're not going to summarize).
	totalReportCount() {
		return((gAction && gAction.dobjList_)
			? gAction.dobjList_.length : 0);
	}

	// Returns the number of reports we're summarizing.
	summarizedReportCount() {
		local n;

		if((gAction == nil) || (gAction.dobjList_ == nil))
			return(0);

		n = 0;
		gAction.dobjList_.forEach(function(o) {
			if(o.obj_.reportManager != self)
				return;
			n += 1;
		});

		return(n);
	}

	// See if we handle the given action type.
	reportManagerMatchAction(act) {
		local i;

		for(i = 1; i <= _reportManagerSummaries.length; i++) {
			if(_reportManagerSummaries[i].matchAction(act)) {
				return(true);
			}
		}

		return(nil);
	}
;

class GeneralReportManager: ReportManager
	reportManagerDefaultSummaries = static [
		TakeSummary,
		TakeFromSummary,
		DropSummary,
		PutOnSummary,
		PutInSummary,
		PutUnderSummary,
		PutBehindSummary,

		TakeFailedSummary
	]

	matchReportDobj(obj) { return(obj != nil); }
;

class SelfReportManager: ReportManager
	matchReportDobj(obj) {
		if((obj == nil) || (gAction == nil))
			return(nil);
		if(gAction.propType(&summarizeDobjProp) == TypeNil)
			return(nil);
		if(obj.propType(gAction.summarizeDobjProp) == TypeNil)
			return(nil);

		return(true);
	}
;
