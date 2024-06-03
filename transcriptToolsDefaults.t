#charset "us-ascii"
//
// transcriptToolsDefaults.t
//
//	Defaults for various bits of the module.
//
//	Broken out into a separate file just to make it easier to find.
//
//
#include <adv3.h>
#include <en_us.h>

#include "transcriptTools.h"

// Global tools instance
transcriptTools: TranscriptTools
	defaultTools = static [
		ReportGrouper,			// required for basic operation
		MarkFailures,			// optional
		MoveFailuresToEndOfTranscript,	// optional
		TranscriptReportManager		// needed for summaries to work
	]
;

modify TranscriptReportManager
	defaultReportManagers = static [
		GeneralReportManager,	// handle common actions for any object
		SelfReportManager	// handles dobjFor() { summarize() }
	]
;


modify GeneralReportManager
	reportManagerDefaultSummaries = static [
		TakeSummary,
		TakeFromSummary,
		DropSummary,
		PutOnSummary,
		PutInSummary,
		PutUnderSummary,
		PutBehindSummary,

		TakeFailedSummary,

		ImplicitTakeSummary
	]
;
