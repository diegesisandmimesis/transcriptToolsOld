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
	count = nil

	failures = nil
	failureCount = nil

	construct(v) {
		vec = v;

		if((v == nil) || (v.length < 1))
			return;

		objs = new Vector(v.length);
		vec.forEach(function(o) {
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
