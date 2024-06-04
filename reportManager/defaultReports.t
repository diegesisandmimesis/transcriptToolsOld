#charset "us-ascii"
//
// defaultReports.t
//
//
#include <adv3.h>
#include <en_us.h>

#include "transcriptTools.h"

class ActionSummary: ReportSummary
	noDistinguisher = true
	gActionExclude = nil
	actionInclude = nil

	matchAction(act) {
		if((gActionExclude != nil) && gAction.ofAnyKind(gActionExclude))
			return(nil);

		if(inherited(act) == true)
			return(true);

		return((actionInclude != nil) && act.ofAnyKind(actionInclude));
	}

	summarize(data) { return('{You/He} <<data.actionClause()>>.</.p>'); }
;

class TakeSummary: ActionSummary
	action = TakeAction
	gActionExclude = TakeFromAction
;

class TakeFromSummary: ActionSummary
	action = TakeFromAction
	actionInclude = TakeAction
;

class DropSummary: ActionSummary
	action = DropAction
	gActionExclude = PutOnAction
;
class PutOnSummary: ActionSummary
	action = PutOnAction
	actionInclude = DropAction
;
class PutInSummary: ActionSummary action = PutInAction;
class PutUnderSummary: ActionSummary action = PutUnderAction;
class PutBehindSummary: ActionSummary action = PutBehindAction;

class TakeFailedSummary: FailureSummary
	action = TakeAction

	summarize(data) {
		return('{You/He} can\'t take <<data.listNamesWithOr()>>. ');
	}
;


class ImplicitTakeSummary: ImplicitSummary
	action = TakeAction

	summarize(data) { return('first taking <<data.listNames()>>'); }
;


// Special summarizer designed for use with SelfReportManager.
// This calls dobjFor(Action) { summarize(data) {} } summarizers.
class SelfSummary: ReportSummary
	active = true

	acceptReport(report) {
		local t;

		// First, we recapitulate many but not all of the stock
		// checks.
		if(!getActive() || (report == nil))
			return(nil);
		if(report.isFailure != isFailure)
			return(nil);
		if(report.isActionImplicit() != isImplicit)
			return(nil);

		// Make sure the report has what we need.
		if((report.dobj_ == nil) || (report.action_ == nil))
			return(nil);

		// Make sure the action allows this kind of summary.  This
		// basically is just a check to see if the action is
		// a TAction, but we DO need the property itself.
		t = report.action_.propType(&summarizeDobjProp);
		if((t == nil) || (t == TypeNil))
			return(nil);

		// Make sure that the direct object has the method the
		// action wants to use.  This will be &summarizeDobjFoozle
		// for FoozleAction
		t = report.dobj_.propType(report.action_.summarizeDobjProp);
		if((t == nil) || (t == TypeNil))
			return(nil);

		// Hurray, we have the method
		return(true);
	}

	// Handle the actual summary.  Instead of doing anything here, we
	// punt to the object method we laboriously checked for above.
	summarize(data) {
		return(data.dobj.(data.vec[1].action_.summarizeDobjProp)(data));
	}
;
