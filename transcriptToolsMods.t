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
	dobj_ = nil
	iobj_ = nil

	reportGroup = nil
	reportSummarizer = nil

	construct() {
		inherited();
		dobj_ = gDobj;
		iobj_ = gIobj;
	}

	getReportSummarizer() {
		if(reportSummarizer != nil)
			return(reportSummarizer);

		if((dobj_ == nil) || (dobj_.reportManager == nil))
			return(nil);

		reportSummarizer = dobj_.reportManager
			.getReportSummarizer(self);

		return(reportSummarizer);
	}
;

modify Action
	summarizeDobjProp = nil

	transcriptToolsAfterActionMain() {
		if(parentAction == nil)
			transcriptTools.afterActionMain();
	}
;

// Modify TAction to check to see if any matching objects have report
// managers.
modify TAction
	afterActionMain() {
		inherited();
		transcriptToolsAfterActionMain();
	}
;

// Modify TIAction to check to see if any matching objects have report
// managers.
modify TIAction
	afterActionMain() {
		inherited();
		transcriptToolsAfterActionMain();
	}
;

modify Thing
	reportName = (name)
	reportManager = nil
	_reportCount = nil
;
