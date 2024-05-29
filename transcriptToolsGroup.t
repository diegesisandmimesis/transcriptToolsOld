#charset "us-ascii"
//
// transcriptGroup.t
//
#include <adv3.h>
#include <en_us.h>

#include "transcriptTools.h"

class ReportGrouper: TranscriptPreprocessor
	toolPriority = 100
	reportGroupClass = ReportGroup

	_reportGroupIndex = perInstance(new Vector)

	addReportToGroup(report) {
		local idx;

		if((report == nil) || !report.ofKind(CommandReport))
			return(nil);

		if((idx = _reportGroupIndex.indexOf(report.iter_)) == nil) {
			_reportGroupIndex.appendUnique(report.iter_);
			parentTools.reportGroups.append(
				reportGroupClass.createInstance());
			idx = _reportGroupIndex.length;
		}

		parentTools.reportGroups[idx].addReport(report);

		return(true);
	}

	preprocess() {
		forEachReport(function(report) {
			if(!checkReport(report))
				return;

			addReportToGroup(report);
		});
	}

	clear() {
		parentTools.reportGroups.setLength(0);
		_reportGroupIndex.setLength(0);
	}
;

class ReportGroup: TranscriptToolsObject
	groupID = nil

	vec = nil
	isFailure = nil
	hasImplicit = nil

	addReport(v) {
		if((v == nil) || !v.ofKind(CommandReport))
			return(nil);

		if((groupID == nil) && (v.iter_ != nil))
			groupID = v.iter_;

		if(vec == nil)
			vec = new Vector(gTranscript.reports_.length);
		vec.appendUnique(v);

		if(v.isFailure == true)
			isFailure = true;

		if(v.isActionImplicit())
			hasImplicit = true;

		return(true);
	}

	getReports() { return(vec); }
;
