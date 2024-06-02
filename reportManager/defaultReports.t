#charset "us-ascii"
//
// defaultReports.t
//
//
#include <adv3.h>
#include <en_us.h>

#include "transcriptTools.h"

class TakeSummary: ReportSummary
	action = TakeAction

	summarize(data) {
		return('{You/He} take{s} <<data.listNames()>>. ');
	}
;

class TakeFromSummary: ReportSummary
	action = TakeFromAction

	summarize(data) {
		return('{You/He} take{s} <<data.listNames()>>
			from <<gIobj.theName>>. ');
	}
;

class DropSummary: ReportSummary
	action = DropAction

	summarize(data) {
		return('{You/He} drop{s} <<data.listNames()>>. ');
	}
;

class PutOnSummary: ReportSummary
	action = PutOnAction

	summarize(data) {
		return('{You/He} put{s} <<data.listNames()>>
			on <<gIobj.theName>>. ');
	}
;

class PutInSummary: ReportSummary
	action = PutInAction

	summarize(data) {
		return('{You/He} put{s} <<data.listNames()>>
			in <<gIobj.theName>>. ');
	}
;

class PutUnderSummary: ReportSummary
	action = PutUnderAction

	summarize(data) {
		return('{You/He} put{s} <<data.listNames()>>
			under <<gIobj.theName>>. ');
	}
;

class PutBehindSummary: ReportSummary
	action = PutBehindAction

	summarize(data) {
		return('{You/He} put{s} <<data.listNames()>>
			behind <<gIobj.theName>>. ');
	}
;

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


class SelfSummary: ReportSummary
	active = nil
	acceptReport(report) {
		if(!getActive() || (report == nil))
			return(nil);
		if(report.isFailure != isFailure)
			return(nil);
		if(report.isActionImplicit() != isImplicit)
			return(nil);
		if(report.action_.propType(&summarizeDobjProp) == TypeNil)
			return(nil);
		if(report.dobj_ == nil)
			return(nil);
		if(report.dobj_.propType(report.action_.summarizeDobjProp)
			== TypeNil)
			return(nil);
		return(true);
	}
	summarize(data) {
		return(data.dobj.(data.vec[1].action_.summarizeDobjProp)(data));
	}
;
