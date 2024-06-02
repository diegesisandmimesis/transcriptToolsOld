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

// Class for high-level "manager"-type objects that can be toggled on
// and off.
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

	toolPriority = 900

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
	moveGroup(grp, idx?) { return(parentTools.moveGroup(grp, idx)); }
	moveReport(r, dst?, t?) { return(parentTools.moveReport(r, dst, t)); }
	replaceReports(v0, v1, t?)
		{ return(parentTools.replaceReports(v0, v1, t)); }
	getReportGroup(report) { return(parentTools.getReportGroup(report)); }

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

	_timestamp = nil

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

	// Returns the first tool, if any, matching the given class
	getTranscriptTool(cls) {
		local i;

		for(i = 1; i <= _transcriptTools.length; i++) {
			if(_transcriptTools[i].ofKind(cls))
				return(_transcriptTools[i]);
		}

		return(nil);
	}

	// Set up our default widgets
	addDefaultTranscriptTools() {
		local obj;

		if(defaultTools == nil)
			return;

		if(!defaultTools.ofKind(Collection))
			defaultTools = [ defaultTools ];

		defaultTools.forEach(function(o) {
			if(getTranscriptTool(o))
				return;

			obj = o.createInstance();
			obj.location = self;
			obj.initializeTranscriptTool();
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

	// Remove the given tool from our list
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

		if(_timestamp == gTurn)
			return(nil);

		return(true);
	}

	// Main report manager loop.
	runTranscriptTools() {
		_timestamp = gTurn;

		clear();		// clear everything, probably redundant
		preprocess();		// run preprocessors
		run();			// run "main" report processing
		postprocess();		// run postprocessors
		clear();		// clean up after ourselves.
	}

	// Main turn lifecycle methods
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

	// Remove the given report from the transcript.
	// First arg is the report.
	// Optional second arg is the transcript.
	removeReport(report, t?) {
		local idx;

		if((t == nil) && ((t = getTranscript()) == nil))
			return(nil);

		if((idx = t.reports_.indexOf(report)) == nil)
			return(nil);

		t.reports_.removeElementAt(idx);

		// If the report was part of a report group, remove it from
		// the group.
		if(report.reportGroup != nil)
			report.reportGroup.removeReport(report);

		return(true);
	}

	// Replace one or more reports with different reports.
	// First arg is a single report or a list of reports to
	// remove.
	// Second arg is the single report or list of reports to
	// insert into the place where the old reports were.
	// Optional third arg is the transcript.
	replaceReports(oldReports, newReports, t?) {
		local idx;

		if((t == nil) && ((t = getTranscript()) == nil))
			return(nil);

		// Both sets of reports have to be defined.
		if((oldReports == nil) || (newReports == nil))
			return(nil);

		// Make sure both sets of reports are lists.
		if(!oldReports.ofKind(Collection))
			oldReports = [ oldReports ];
		if(!newReports.ofKind(Collection))
			newReports = [ newReports ];

		// Figure out where to insert the new reports.
		idx = getFirstIndexOfReports(oldReports, t);

		// Check the insertion point
		if((idx == nil) || (idx > t.reports_.length + 1))
			idx = t.reports_.length + 1;
			
		// Add the new reports
		newReports.forEach(function(o) {
			t.reports_.insertAt(idx, o);
			idx += 1;
		});

		// Remove the old reports.
		// Done AFTER adding the new reports because removing them
		// might change the transcript enough that the index we
		// computed above would have to be re-computed
		oldReports.forEach({ x: removeReport(x, t) });

		return(true);
	}

	// Given a list of reports, return the index in the transcript
	// of the earliest one, which some fiddly logic for using report
	// groups, if they're defined for these reports
	getFirstIndexOfReports(lst, t?) {
		local grp, grp0, idx;

		if((t == nil) && ((t = getTranscript()) == nil))
			return(nil);

		idx = nil;
		grp0 = nil;

		// Figure out the earliest group for these reports.
		lst.forEach(function(o) {
			if((grp = getReportGroup(o)) == nil)
				return;
			if((grp0 == nil) || (grp.groupID < grp0.groupID))
				grp0 = grp;
		});

		// If we got a group, ask it the location of the first
		// full report.  We use this as the index because sometimes
		// our group will contain bookkeeping reports that AREN'T
		// part of the report vector we're fiddling with, and we
		// and so we don't necessarily want the first report of
		// the group our reports are from
		if(grp0 != nil)
			idx = grp0.indexOfFirstFullReport();

		// Fallback if we're not using groups.  Probably never
		// needed.
		if(idx == nil) {
			idx = t.reports_.length;
			lst.forEach(function(o) {
				local i;
				if(((i = t.reports_.indexOf(o)) != nil)
					&& (i < idx))
					idx = i;
			});
		}

		return(idx);
	}

	getReportGroup(report) { return(report.reportGroup); }
;

transcriptTools: TranscriptTools
	defaultTools = static [
		ReportGrouper,
		MarkFailures,
		MoveFailuresToEndOfTranscript,
		TranscriptReportManager
	]
;
