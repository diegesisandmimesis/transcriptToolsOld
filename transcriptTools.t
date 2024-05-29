#charset "us-ascii"
//
// transcriptTools.t
//
#include <adv3.h>
#include <en_us.h>

#include "transcriptTools.h"

// Module ID for the library
transcriptToolsModuleID: ModuleID {
        name = 'Transcript Tools Library'
        byline = 'Diegesis & Mimesis'
        version = '1.0'
        listingOrder = 99
}

// Generic class for stuff in the module.
class TranscriptToolsObject: Syslog syslogID = 'transcriptTools';

class TranscriptToolsWidget: TranscriptToolsObject
	active = true

	getActive() { return(active == true); }
	setActive(v) { active = (v ? true : nil); }
;


// Abstract class for widgets that operate on (group, sort, or whatever)
// the entire transcript.
class TranscriptTool: TranscriptToolsWidget
	// The TranscriptTools instance we're a part of
	parentTools = nil

	// Called at preinit
	initializeTranscriptTool() {
		if(location == nil) return;
		location.addTranscriptTool(self);
	}

	// Convenience wrappers for methods defined on TranscriptTools
	forEachReport(fn) { parentTools.forEachReport(fn); }
	forEachReportGroup(fn) { parentTools.forEachReportGroup(fn); }
	checkReport(r) { return(true); }
	getTranscript() { return(parentTools.getTranscript()); }
	getGroup(report) { return(parentTools.getGroup(report)); }
	moveGroup(grp, idx) { return(parentTools.moveGroup(grp, idx)); }

	// Wrappers for the base methods, only calls them when we're active
	_preprocess() { if(getActive()) preprocess(); }
	_run() { if(getActive()) run(); }
	_postprocess() { if(getActive()) postprocess(); }

	// Stub methods to be overwritten by subclasses
	preprocess() {}
	run() {}
	postprocess() {}
	clear() {}
;

// A couple of "base subclasses" for transcript parsing widgets.  Pure sugar.
class TranscriptPreprocessor: TranscriptTool;
class TranscriptPostprocessor: TranscriptTool;

// Base class for transcript-rewriting logic.
// In theory this is an abstract class so we can create pre-transcript
// instances that do different things.  But in practice all you probably
// want is the stock transcriptTools instance declared below.
class TranscriptTools: TranscriptToolsWidget
	// Optional list of TranscriptTool classes to add instances of
	// to ourselves at preinit
	defaultTools = nil

	// List of current reports in the transcript, sorted into groups
	// by CommandReport.iter_
	reportGroups = perInstance(new Vector)

	// The transcript we're managing
	_transcript = nil

	// List of TranscriptTool instances we're using
	_transcriptTools = perInstance(new Vector())

	getTranscript() { return(_transcript ? _transcript : gTranscript); }
	setTranscript(v) { _transcript = v; }

	// Called at preinit
	initializeTranscriptTools() {
		addDefaultTranscriptTools();
		sortTranscriptTools();
	}

	// Set up our default widgets
	addDefaultTranscriptTools() {
		if(defaultTools == nil)
			return;

		if(!defaultTools.ofKind(Collection))
			defaultTools = [ defaultTools ];

		defaultTools.forEach(function(o) {
			addTranscriptTool(o.createInstance());
		});
	}

	// Add the given widget to our list
	addTranscriptTool(obj) {
		if((obj == nil) || !obj.ofKind(TranscriptTool))
			return(nil);

		_transcriptTools.append(obj);
		obj.parentTools = self;

		return(true);
	}

	removeTranscriptTool(obj) { _transcriptTools.removeElement(obj); }

	// Order the list of tools by their numeric toolPriority
	sortTranscriptTools() {
		_transcriptTools.sort(true, {
			a, b: b.toolPriority - a.toolPriority
		});
	}

	// TAction and TIActions call us from their afterActionMain().  This
	// is the main external hook for the report manager logic.
	afterActionMain() {
		if(!checkTranscriptTools())
			return;

		runTranscriptTools();
	}

	// See if we should run this turn.  Returns true if we should,
	// nil otherwise.
	checkTranscriptTools() {
		// Make sure we're active.
		if(getActive() != true)
			return(nil);

		return(true);
	}

	// Main report manager loop.
	runTranscriptTools() {
		clear();		// clear everything, probably redundant
		preprocess();		// run preprocessors
		run();			// run "main" report processing
		postprocess();		// run postprocessors
		clear();		// clean up after ourselves.
	}

	preprocess() { forEachTool({ x: x._preprocess() }); }
	run() { forEachTool({ x: x._run() }); }
	postprocess() { forEachTool({ x: x._postprocess() }); }
	clear() { forEachTool({ x: x.clear() }); }

	// Convenience methods for iterating over each report, report group,
	// and transcript tool.
	forEachReport(fn) {
		local t;

		if((t = getTranscript()) == nil)
			return;

		t.reports_.forEach({ x: (fn)(x) });
	}
	forEachReportGroup(fn) { reportGroups.forEach({ x: (fn)(x) }); }
	forEachTool(fn) { _transcriptTools.forEach({ x: (fn)(x) }); }

	// Get the report group for the given report.
	getGroup(report) {
		return(reportGroups.valWhich({ x: x.groupID == report.iter_ }));
	}

	// Move the given group to the requested position.  The position is
	// an index in the group array.
	moveGroup(grp, idx?) {
		local idx0;

		// If no index is given, use zero.  Note that this means
		// "add to the end of the array", not "insert as the
		// zeroth element"
		if(idx == nil)
			idx = 0;

		// If the group isn't a member of the group array, bail
		if((idx0 = reportGroups.indexOf(grp)) == nil)
			return(nil);

		// Remove the group from the array
		reportGroups.removeElementAt(idx0);

		// If the "destination" index is after the index we
		// just yoinked the group from, then we decrement
		// the destination index by one to reflect the shortening
		// of the array
		if(idx > idx0)
			idx -= 1;

		// Insert the group into its new location
		reportGroups.insertAt(idx, grp);

		// Handle shuffling the individual reports in the group
		_moveGroupReports(grp);

		return(true);
	}

	// Move the reports in the given group to their appropriate
	// location in the transcript.
	_moveGroupReports(grp) {
		local grp0, i, idx, t;

		// If we don't have a group, or the group is empty, bail
		if((grp == nil) || (grp.vec == nil))
			return(nil);

		// Make sure we have a transcript to manipulate
		if((t = getTranscript()) == nil)
			return(nil);

		// Get the index of the given group in the group list.
		if((i = reportGroups.indexOf(grp)) == nil)
			return(nil);

		if(i == 1) {
			// If it's the first group, then we're moving
			// reports to the start of the transcript.
			idx = 1;
		} else {
			// We're NOT the first group, so figure out which
			// group is immediately before us.
			grp0 = reportGroups[i - 1];

			// Now get the index of the LAST report in the
			// group before us.  This is where we're going
			// to move our reports to.
			if((idx = grp0.indexOfLastReport()) == nil) {
				return(nil);
			}

			idx += 1;
		}

		// Now we go through our list of reports.
		grp.vec.forEach(function(o) {
			idx = moveReport(o, idx, t) + 1;
		});

		return(true);
	}

	// Move the given report.
	// Optional second arg is the index (in the transcript's report
	// vector) to move the report to.  If none is given the report
	// will be appended onto the end of the transcript.
	// Optional third arg is the transcript, defaulting to the
	// value of getTranscript() if none is given.
	moveReport(report, moveTo?, t?) {
		local moveFrom;

		if((t == nil) && ((t = getTranscript()) == nil))
			return(nil);

		if((moveTo == nil) || (moveTo > t.reports_.length + 1))
			moveTo = t.reports_.length + 1;

		if((moveFrom = t.reports_.indexOf(report)) == nil)
			return(nil);

		t.reports_.removeElementAt(moveFrom);
		if(moveTo > moveFrom)
			moveTo -= 1;

		t.reports_.insertAt(moveTo, report);

		return(moveTo);
	}
;

transcriptTools: TranscriptTools
	defaultTools = static [ ReportGrouper, MoveFailuresToEndOfTranscript ]
;
