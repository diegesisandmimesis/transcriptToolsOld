#charset "us-ascii"
//
// transcriptPreinit.t
//
#include <adv3.h>
#include <en_us.h>

#include "transcriptTools.h"

transcriptToolsPreinit: PreinitObject
	execute() {
		forEachInstance(TranscriptTool, function(o) {
			o.initializeTranscriptTool();
		});
		forEachInstance(TranscriptTools, function(o) {
			o.initializeTranscriptTools();
		});
	}
;
