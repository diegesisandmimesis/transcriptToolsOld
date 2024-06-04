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
	getReportSummarizer(lst?) {
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
			.getReportSummarizer(self, lst);

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

	ofAnyKind(val) {
		local i;

		if(!val.ofKind(Collection))
			return(self.ofKind(val));

		for(i = 1; i <= val.length; i++) {
			if(self.ofKind(val[i]))
				return(true);
		}

		return(nil);
	}
;

// Ping transcriptTools after every TAction
modify TAction
	conjugation = nil

	afterActionMain() {
		inherited();
		transcriptToolsAfterActionMain();
	}

	verbPattern = static new RexPattern('(.*)(?=/)')

	verbName() {
		rexMatch(verbPattern, verbPhrase);
		return(rexGroup(1)[3]);
	}

	conjugateVerb(str) {
		if(conjugation != nil)
			return(conjugation);

		return(gActor.conjugateRegularVerb(str));
	}

	actionClause(dobjStr, iobjStr?) {
		return(conjugateVerbPhrase(_actionClause(dobjStr, iobjStr)));
	}
	
	conjugateVerbPhrase(str) {
		local cName, vName;

		vName = verbName();
		cName = conjugateVerb(vName);

		if(vName != cName)
			str = rexReplace('%<' + vName + '%>', str,
				cName, ReplaceAll);

		return(str);
	}

	_actionClause(dobjStr, iobjStr?){
		return(getVerbPhrase1(true, verbPhrase, dobjStr, nil));
	}
;

// Ping transcriptTools after every TIAction
modify TIAction
	afterActionMain() {
		inherited();
		transcriptToolsAfterActionMain();
	}

	_actionClause(dobjStr, iobjStr) {
		return(getVerbPhrase2(true, verbPhrase, dobjStr, nil, iobjStr));
	}
;

modify Thing
	reportName = (name)	// name to use in distinguisher announcements
	reportManager = nil	// report manager for this object, if any
	_reportCount = nil	// number of matching objects in report, if
				//	we've been chosed as the representative
				//	dobj for a report summary
;
