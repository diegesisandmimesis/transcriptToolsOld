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

class TranscriptToolsObject: Syslog
	syslogID = 'transcriptTools'
;

class TranscriptTools: TranscriptToolsObject
	active = true

	reportGroupClass = ReportGroup

	_reportGroup = perInstance(new LookupTable())

	_transcript = nil

	getActive() { return(active); }

	getTranscript() { return(_transcript ? _transcript : gTranscript); }
	setTranscript(v) { _transcript = v; }

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
		groupReports();
	}

	clear() {
		_clearReportGroups();
	}

	_clearReportGroups() {
		_reportGroup.keysToList().forEach(function(o) {
			_reportGroup.removeElement(o);
		});
		
	}

	forEachReport(fn) {
		local t;

		if((t = getTranscript()) == nil)
			return;

		t.reports_.forEach(fn);
	}

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
;

transcriptTools: TranscriptTools;
