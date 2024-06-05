#charset "us-ascii"
//
// transcriptToolsDistinguisher.t
//
//	TranscriptTool class and related stuff for handling report managers.
//
//
#include <adv3.h>
#include <en_us.h>

#include "transcriptTools.h"

// Data structure for handling the deliberations about whether or not
// to include distinguisher announcements with report summaries.
class DistinguisherConfig: object
	distinguishers = 0
	summarizers = 0
	summarizedDobjCount = 0
	transcriptDobjCount = 0
	noDistinguisher = nil

	setSummarizerVector(lst) {
		local v;

		if(lst == nil)
			return;

		v = new Vector(lst.length);
		lst.forEach(function(o) {
			o.reports.forEach({ x: v.appendUnique(x.dobj_) });
			if(!o.summarizer.isImplicit)
				summarizers += 1;
		});

		summarizedDobjCount = v.length;

		if(gAction && gAction.dobjList_)
			transcriptDobjCount = gAction.dobjList_.length;
	}

	countDistinguishers(lst) {
		distinguishers = lst.length;
	}

	check() {
		if(((distinguishers > 1) || (summarizers > 1)
			|| (summarizedDobjCount != transcriptDobjCount)))
			return(true);
		return(!noDistinguisher);
	}

	clear() {
		distinguishers = 0;
		summarizers = 0;
		summarizedDobjCount = 0;
		transcriptDobjCount = 0;
		noDistinguisher = nil;
	}
;
