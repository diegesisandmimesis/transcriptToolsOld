#charset "us-ascii"
//
// transcriptGroup.t
//
//	Report grouping logic.
//
//	By default we group reports by their iter_ property.
//
#include <adv3.h>
#include <en_us.h>

#include "transcriptTools.h"

class ReportGrouper: TranscriptPreprocessor
	// We should probably be the first preprocessor to run
	toolPriority = 100

	// Class for our groups
	reportGroupClass = ReportGroup

	addReportToGroup(report) {
		local grp;

		if((report == nil) || !report.ofKind(CommandReport))
			return(nil);

		// If we don't have a group for this report, create one
		if((grp = getGroup(report)) == nil) {
			grp = reportGroupClass.createInstance();
			grp.transcript = getTranscript();

			// We add the groups to a vector owned by our
			// TranscriptTools parent instance, so other
			// tools can see them.
			parentTools.reportGroups.append(grp);
		}

		// Add the report to the group
		grp.addReport(report);

		return(true);
	}

	// Lifecycle method for the tool, called by our TranscriptTools
	// parent
	preprocess() {
		forEachReport(function(report) {
			if(!checkReport(report))
				return;

			addReportToGroup(report);
		});
	}

	// Clear out our parent's groups
	clear() { parentTools.reportGroups.setLength(0); }
;

// Class for grouping reports
class ReportGroup: TranscriptToolsObject
	// Numeric group ID.  Probably the iter_ from the original reports
	groupID = nil

	// The transcript the reports are part of
	transcript = nil

	// Vector of the reports in this group
	vec = nil

	// Boolean indicating if the reports in this group are part of a
	// failed action
	isFailure = nil

	// Boolean indicating whether this group contains one or more
	// implicit actions
	hasImplicit = nil

	// The resolved report summarizer for this group of reports
	reportSummarizer = nil

	getTranscript() { return(transcript); }

	addReport(v) {
		if((v == nil) || !v.ofKind(CommandReport))
			return(nil);

		// If the group doesn't have an assigned group ID,
		// use the report's iter_ property
		if((groupID == nil) && (v.iter_ != nil))
			groupID = v.iter_;

		// Create the vector for the reports if it doesn't exist
		if(vec == nil)
			vec = new Vector(gTranscript.reports_.length);

		vec.appendUnique(v);

		// Handle setting the flags
		if(v.isFailure == true)
			isFailure = true;

		if(v.isActionImplicit())
			hasImplicit = true;

		// Mark the report as belonging to this group.  Entirely
		// to save cycles looking it up later
		v.reportGroup = self;

		return(true);
	}

	// Remove the given report from this group
	removeReport(v) {
		vec.removeElement(v);
		v.reportGroup = nil;
	}

	// Return the report vector
	getReports() { return(vec); }

	// Convenience method for iterating over the reports in the group
	forEachReport(fn) { vec.forEach({ x: (fn)(x) }); }

	// Returns the index in the transcript of the first report in
	// this group
	indexOfFirstReport() {
		local i, idx, t;

		if((vec == nil) || !vec.length)
			return(nil);

		if((t = getTranscript()) == nil)
			return(nil);

		for(i = 1; i <= vec.length; i++) {
			if((idx = t.reports_.indexOf(vec[i])) != nil)
				return(idx);
		}

		return(nil);
	}

	// Returns the index in the transcript of the first full report
	// in this group.  This skips announcements and so on.  Used to
	// figure out where to insert summaries.
	indexOfFirstFullReport() {
		local idx, lastIdx, o, t;

		if((t = getTranscript()) == nil)
			return(nil);

		// We need to have a first and last index to proceed
		if((idx = indexOfFirstReport()) == nil)
			return(nil);
		if((lastIdx = indexOfLastReport()) == nil)
			return(nil);

		// Traverse the range between the first and last report,
		// looking for any non-skippable (announcement, default)
		// reports
		while(idx <= lastIdx) {
			o = t.reports_[idx];

			if(!isReportSkippable(o))
				return(idx);

			idx += 1;
		}

		return(lastIdx);
	}

	// Returns the index in the transcript of the last report in the group
	indexOfLastReport() {
		local i, idx, t;

		if((vec == nil) || !vec.length)
			return(nil);
		if((t = getTranscript()) == nil)
			return(nil);

		for(i = vec.length; i > 0; i--) {
			if((idx = t.reports_.indexOf(vec[i])) != nil)
				return(idx);
		}

		return(nil);
	}

	// Returns the index in our report vector of the given report
	getReportIndex(report) {
		if(vec == nil)
			return(nil);
		return(vec.indexOf(report));
	}

	// Get a report summarizer for this group.
	// This assumes that the first summarizer in the group will be
	// the one used by the group as a whole.  If this ISN'T the case,
	// the other logic will have to be used.
	getReportSummarizer() {
		local i, s;

		if(vec == nil)
			return(nil);

		for(i = 1; i <= vec.length; i++) {
			if((s = vec[i].getReportSummarizer()) != nil)
				return(s);
		}

		return(nil);
	}
;

// Standalone function that evaluates which reports count as "full" for
// our purposes above.
function
isReportSkippable(report) {
	return(report.ofKind(ImplicitActionAnnouncement)
		|| report.ofKind(MultiObjectAnnouncement)
		|| report.ofKind(DefaultCommandReport)
		|| report.ofKind(ConvBoundaryReport));
}
