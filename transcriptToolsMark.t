#charset "us-ascii"
//
// transcriptMark.t
//
//	Tools to mark reports transcript-wide
//
//
#include <adv3.h>
#include <en_us.h>

#include "transcriptTools.h"

// Markup tools run after grouping and sorting by default
class TranscriptMarker: TranscriptPreprocessor
	toolPriority = 300
;

// Go through and mark all reports in a group as failures if the group
// itself is marked as a failure
class MarkFailures: TranscriptMarker
	preprocess() {
		forEachReportGroup(function(o) {
			if(!o.isFailure)
				return;
			o.forEachReport({ x: x.isFailure = true });
		});
	}
;
