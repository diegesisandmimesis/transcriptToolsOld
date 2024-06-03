#charset "us-ascii"
//
// transcriptToolsMods.t
//
//	Modifications to base TADS3/adv3 classes.
//
//
#include <adv3.h>
#include <en_us.h>

#include "transcriptTools.h"

// Remember the direct object in every command report.
// This approach is from Eric Eve's "Manipulating the Transcript"
//	https://tads.org/t3doc/doc/techman/t3transcript.htm
modify CommandReport
	dobj_ = nil			// to remember gDobj
	iobj_ = nil			// to remember gIobj

	reportGroup = nil		// group we belong to
	reportSummarizer = nil		// summarizer for this report

	construct() {
		inherited();
		dobj_ = gDobj;
		iobj_ = gIobj;
	}

	// Figure out what summarizer, if any, to use for this report.
	getReportSummarizer() {
		// If we already figured it out, use the saved value
		if(reportSummarizer != nil)
			return(reportSummarizer);

		// If we don't have a report manager, we don't have a
		// summarizer
		if((dobj_ == nil) || (dobj_.reportManager == nil))
			return(nil);

		// As the report manager who should summarize us, remembering
		// the result
		reportSummarizer = dobj_.reportManager
			.getReportSummarizer(self);

		return(reportSummarizer);
	}
;

modify Action
	// Property for naming the action-specific summarizer property
	summarizeDobjProp = nil

	// Utility method to call transcriptTools
	transcriptToolsAfterActionMain() {
		if(parentAction == nil)
			transcriptTools.afterActionMain();
	}
;

// Ping transcriptTools after every TAction
modify TAction
	afterActionMain() {
		inherited();
		transcriptToolsAfterActionMain();
	}
;

// Ping transcriptTools after every TIAction
modify TIAction
	afterActionMain() {
		inherited();
		transcriptToolsAfterActionMain();
	}
;

modify Thing
	reportName = (name)	// name to use in distinguisher announcements
	reportManager = nil	// report manager for this object, if any
	_reportCount = nil	// number of matching objects in report, if
				//	we've been chosed as the representative
				//	dobj for a report summary
;
