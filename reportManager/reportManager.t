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
	//_distinguisherFlag = nil

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
			if(matchReportAction(o.action))
				return;

			// Remember that we need to add this default.
			l.appendUnique(o);
		});

		// Go through our list of defaults we don't have,
		// adding them.
		l.forEach({ x: addReportManagerSummary(x.createInstance()) });
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

	getDistinguisherFlag() {
		return(parentTools ? parentTools._distinguisherFlag == true
			: nil);
	}

	getReportSummarizer(report) {
		local i;

		if(!matchReportDobj(report.dobj_))
			return(nil);

		for(i = 1; i <= _reportManagerSummaries.length; i++) {
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
				return(_reportManagerSummaries[i]);
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

	forEachSummary(fn) {  _reportManagerSummaries.forEach({ x: fn(x) }); }
;

// General non-object-specific report manager.
class GeneralReportManager: ReportManager
	reportManagerDefaultSummaries = nil

	matchReportDobj(obj) { return(obj != nil); }
;

// Report manager that handles dobjFor(Action) { summarize(data) {} }
// logic.
class SelfReportManager: ReportManager
	// SelfSummary is a bespoke summarizer designed for use with
	// this report manager.
	reportManagerDefaultSummaries = static [ SelfSummary ]

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
