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

class TranscriptToolsObject: Syslog syslogID = 'transcriptTools';

class TranscriptTool: TranscriptToolsObject
	parentTools = nil

	initializeTranscriptTool() {
		if(location == nil) return;
		location.addTranscriptTool(self);
	}

	forEachReport(fn) { parentTools.forEachReport(fn); }
	forEachReportGroup(fn) { parentTools.forEachReportGroup(fn); }
	checkReport(r) { return(true); }

	preprocess() {}
	run() {}
	postprocess() {}
	clear() {}

	getTranscript() { return(parentTools.getTranscript()); }
	getGroup(report) { return(parentTools.getGroup(report)); }
	moveGroup(grp, idx) { return(parentTools.moveGroup(grp, idx)); }
;

class TranscriptPreprocessor: TranscriptTool;

class TranscriptTools: TranscriptToolsObject
	active = true

	defaultTools = nil

	_transcript = nil
	_transcriptTools = perInstance(new Vector())

	reportGroups = perInstance(new Vector)

	getActive() { return(active); }

	getTranscript() { return(_transcript ? _transcript : gTranscript); }
	setTranscript(v) { _transcript = v; }

	initializeTranscriptTools() {
		addDefaultTranscriptTools();
		sortTranscriptTools();
	}

	addDefaultTranscriptTools() {
		if(defaultTools == nil)
			return;

		if(!defaultTools.ofKind(Collection))
			defaultTools = [ defaultTools ];

		defaultTools.forEach(function(o) {
			addTranscriptTool(o.createInstance());
		});
	}

	addTranscriptTool(obj) {
		if((obj == nil) || !obj.ofKind(TranscriptTool))
			return(nil);

		_transcriptTools.append(obj);
		obj.parentTools = self;

		return(true);
	}

	removeTranscriptTool(obj) { _transcriptTools.removeElement(obj); }

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
		clear();
		preprocess();
		run();
		postprocess();
//forEachReportGroup({ x: x._debugGroup() });
		clear();
	}

	preprocess() { forEachTool({ x: x.preprocess() }); }
	run() { forEachTool({ x: x.run() }); }
	postprocess() { forEachTool({ x: x.postprocess() }); }
	clear() { forEachTool({ x: x.clear() }); }

	forEachReport(fn) {
		local t;

		if((t = getTranscript()) == nil)
			return;

		t.reports_.forEach({ x: (fn)(x) });
	}

	forEachReportGroup(fn) { reportGroups.forEach({ x: (fn)(x) }); }
	forEachTool(fn) { _transcriptTools.forEach({ x: (fn)(x) }); }

	getGroup(report) {
		return(reportGroups.valWhich({ x: x.groupID == report.iter_ }));
	}

	moveGroup(grp, idx) {
		local idx0;

		if(idx == nil)
			idx = 0;

		if((idx0 = reportGroups.indexOf(grp)) == nil)
			return(nil);

		reportGroups.removeElementAt(idx0);
		if(idx > idx0)
			idx -= 1;

		reportGroups.insertAt(idx, grp);

		_moveGroupReports(grp);

		return(true);
	}

	_moveGroupReports(grp) {
		local grp0, i, idx0, idx1, t;

		if((grp == nil) || (grp.vec == nil))
			return(nil);

		if((t = getTranscript()) == nil)
			return(nil);

		if((i = reportGroups.indexOf(grp)) == nil)
			return(nil);

		if(i == 1) {
			idx0 = 1;
		} else {
			grp0 = reportGroups[i - 1];
			if((idx0 = grp0.indexOfLastReport()) == nil) {
				return(nil);
			}
		}
		grp.vec.forEach(function(o) {
			if(idx0 > t.reports_.length)
				idx0 = 0;

			if((idx1 = t.reports_.indexOf(o)) == nil)
				return;
			
			t.reports_.removeElementAt(idx1);

			if(idx0 > idx1)
				idx0 -= 1;

			t.reports_.insertAt(idx0, o);

			idx0 += 1;
		});

		return(true);
	}

	moveReport(report, idx) {
		local idx0, t;

		if((t = getTranscript()) == nil)
			return(nil);

		if((idx0 = t.reports_.indexOf(report)) == nil)
			return(nil);


		t.reports_.removeElementAt(idx0);
		if(idx > idx0)
			idx -= 1;

		t.reports_.insertAt(idx, report);

		return(true);
	}
;

transcriptTools: TranscriptTools
	defaultTools = static [ ReportGrouper, MoveFailuresToEndOfTranscript ]
;
