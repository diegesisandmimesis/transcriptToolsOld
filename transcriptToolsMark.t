#charset "us-ascii"
//
// transcriptSort.t
//
#include <adv3.h>
#include <en_us.h>

#include "transcriptTools.h"

class TranscriptMarker: TranscriptPreprocessor
	toolPriority = 300
;

class MarkFailures: TranscriptMarker
	preprocess() {
		forEachReportGroup(function(o) {
			if(!o.isFailure)
				return;
			o.forEachReport({ x: x.isFailure = true });
		});
	}
;
