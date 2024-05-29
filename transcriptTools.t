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
forEachReportGroup({ x: x._debugGroup() });
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

/*
	groupReports() {
		forEachReport(function(o) {
			if(!checkReport(o))
				return;

			addReportToGroup(o);
		});
	}

	addReportToGroup(rpt) {
		if((rpt == nil) || !rpt.ofKind(CommandReport))
			return(nil);

		if(_reportGroup[rpt.iter_] == nil) {
			_reportGroup[rpt.iter_]
				= reportGroupClass.createInstance();
		}
		_reportGroup[rpt.iter_].addReport(rpt);

		return(true);
	}

	checkReport(r) {
		if((r == nil) || !r.ofKind(CommandReport))
			return(nil);
		return(true);
	}
*/
;

transcriptTools: TranscriptTools
	defaultTools = static [ ReportGrouper, MoveFailuresToEndOfTranscript ]
;
