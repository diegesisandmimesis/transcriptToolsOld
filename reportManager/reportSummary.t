#charset "us-ascii"
//
// reportSummary.t
//
#include <adv3.h>
#include <en_us.h>

#include "transcriptTools.h"

class CommandReportSummary: MainCommandReport;

class ReportSummaryData: object
	vec = nil
	objs = nil
	dobj = nil
	iobj = nil
	action = nil
	count = nil

	failures = nil
	failureCount = nil

	construct(v) {
		vec = v;

		if((v == nil) || (v.length < 1))
			return;

		if(gIobj != nil)
			iobj = gIobj;

		objs = new Vector(v.length);
		vec.forEach(function(o) {
			if((action == nil) && o.action_ != nil)
				action = o.action_;
			objs.appendUnique(o.dobj_);
		});

		count = objs.length;

		if(objs.length < 1)
			return;

		dobj = objs[1];
		if(dobj)
			dobj._reportCount = count;
	}

	listNames() { return(equivalentLister.makeSimpleList(objs)); }
	listNamesWithAnd() { return(listNames()); }
	listNamesWithOr() { return(equivalentOrLister.makeSimpleList(objs)); }

	listIobj() { return(iobj ? iobj.theName : nil); }

	getAction() {
		if(iobj == nil)
			return(action);
		if(!action.ofKind(TIAction))
			vec.forEach(function(o) {
				if(o.action_ && o.action_.ofKind(TIAction))
					action = o.action_;
			});
		return(action);
	}

	actionClause() {
		return(getAction().actionClause(listNames(), listIobj()));
	}
	actionClauseWithAnd() { return(actionClause()); }
	actionClauseWithOr() {
		return(getAction().actionClause(listNamesWithOr(), listIobj()));
	}
;

class ReportSummary: TranscriptToolsObject
	active = true

	action = nil

	reportManager = nil
	isFailure = nil
	isImplicit = nil

	commandReportSummaryClass = CommandReportSummary

	getActive() { return(active == true); }
	setActive(v) { active = (v ? true : nil); }

	initializeReportSummary() {
		if(location == nil)
			return(nil);

		if(location.ofKind(ReportManager)) {
			location.addReportManagerSummary(self);
			return(true);
		}

		return(nil);
	}

	matchAction(act) {
		if(!getActive())
			return(nil);

		if((act == nil) || (action == nil))
			return(nil);

		return(act.ofKind(action));
	}

	acceptGroup(grp) { return(getActive()); }

	// Decided whether or no we want to summarize this report
	acceptReport(report) {
		if(!getActive())
			return(nil);

		if(report == nil)
			return(nil);

		if(!matchAction(report.action_))
			return(nil);

		if(report.isFailure != isFailure)
			return(nil);

		if(report.isActionImplicit() != isImplicit)
			return(nil);

		return(true);
	}

	_summarize(data) {
		reportSummaryMessageParams(data.dobj);
		return(summarize(data));
	}

	summarize(data) {}

	reportSummaryMessageParams(obj?) {}

	cleanupReports(action) {
		local v;

		v = new Vector();
		forEachReport(function(o) {
			if(o.action_ && o.action_.ofKind(action))
				v.append(o);
		});
		v.forEach({ x: removeReport(x) });
	}

	forEachReport(fn) { reportManager.parentTools.forEachReport(fn); }
	removeReport(r) { reportManager.parentTools.removeReport(r); }
;

class FailureSummary: ReportSummary
	isFailure = true
;

class ImplicitSummary: ReportSummary
	isImplicit = true

	acceptReport(report) {
		if(inherited(report) != true)
			return(nil);

		return(report.isActionImplicit() == true);
	}
;

class ActionSummary: ReportSummary
	noDistinguisher = true
	gActionExclude = nil
	actionInclude = nil
	defaultProp = nil

	acceptReport(report) {
		//if((defaultProp != nil) && (report.messageProp_ != defaultProp))
			//return(nil);
		return(inherited(report));
	}

	matchAction(act) {
		if((gActionExclude != nil) && gAction.ofAnyKind(gActionExclude))
			return(nil);

		if(inherited(act) == true)
			return(true);

		if(!gAction.ofAnyKind(action))
			return(nil);

		return((actionInclude != nil) && act.ofAnyKind(actionInclude));
	}

	summarize(data) { return('{You/He} <<data.actionClause()>>.</.p>'); }
;
