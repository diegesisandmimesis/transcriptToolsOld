#charset "us-ascii"
//
// transcriptSort.t
//
//	Tools to sort the transcript
//
//
#include <adv3.h>
#include <en_us.h>

#include "transcriptTools.h"

// Sorting tools run after grouping tools and before marking tools by default
class TranscriptSorter: TranscriptPreprocessor
	toolPriority = 200
;

// Simple sorter that moves failed reports to the end of the transcript,
// preserving report grouping
class MoveFailuresToEndOfTranscript: TranscriptSorter
	preprocess() {
		local idx, l, len;

		l = parentTools.reportGroups;
		len = l.length;

		while(((idx = l.indexWhich({ x: x.isFailure })) != nil)
			 && (idx < len)) {

			moveGroup(l[idx], 0);

			len -= 1;
		}
	}
;
