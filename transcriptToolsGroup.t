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

	addReportToGroup(report) {
		local grp;

		if((report == nil) || !report.ofKind(CommandReport))
			return(nil);

		if((grp = getGroup(report)) == nil) {
			grp = reportGroupClass.createInstance();
			grp.transcript = getTranscript();
			parentTools.reportGroups.append(grp);
		}

		grp.addReport(report);

		return(true);
	}

	preprocess() {
		forEachReport(function(report) {
			if(!checkReport(report))
				return;

			addReportToGroup(report);
		});
	}

	clear() { parentTools.reportGroups.setLength(0); }
;

class ReportGroup: TranscriptToolsObject
	groupID = nil

	transcript = nil

	reportSummarizer = nil

	vec = nil
	isFailure = nil
	hasImplicit = nil

	getTranscript() { return(transcript); }

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

	forEachReport(fn) { vec.forEach({ x: (fn)(x) }); }

	indexOfFirstReport() {
		local t;

		if((vec == nil) || !vec.length)
			return(nil);
		if((t = getTranscript()) == nil)
			return(nil);

		return(t.indexOf(vec[1]));
	}

	indexOfLastReport() {
		local t;

		if((vec == nil) || !vec.length)
			return(nil);
		if((t = getTranscript()) == nil)
			return(nil);

		return(t.reports_.indexOf(vec[vec.length]));
	}

	getReportSummarizer() {
		local r, s;

		if(vec == nil)
			return(nil);

		r = nil;
		vec.forEach(function(o) {
			if((s = o.getReportSummarizer()) != nil)
				r = s;
		});

		return(r);
	}
;
