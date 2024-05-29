#charset "us-ascii"
//
// transcriptSort.t
//
#include <adv3.h>
#include <en_us.h>

#include "transcriptTools.h"

class TranscriptSorter: TranscriptPreprocessor
	toolPriority = 200
;

class MoveFailuresToEndOfTranscript: TranscriptSorter
	preprocess() {
		local idx, l, len;

		l = parentTools.reportGroups;
		len = l.length;

		while(((idx = l.indexWhich({ x: x.isFailure })) != nil)
			 && (idx < len)) {

			l.append(l[idx]);
			l.removeElementAt(idx);

			len -= 1;
		}
	}
;
