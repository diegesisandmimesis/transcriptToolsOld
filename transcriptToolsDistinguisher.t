#charset "us-ascii"
//
// transcriptToolsDistinguisher.t
//
//	Data structure used by the report manager logic to decide
//	whether or not to use distinguisher announcements
//
//
#include <adv3.h>
#include <en_us.h>

#include "transcriptTools.h"

// Data structure for handling the deliberations about whether or not
// to include distinguisher announcements with report summaries.
class DistinguisherConfig: object
	distinguishers = 0		// number of distinguisher announcements
	summarizers = 0			// number of summarizers
	summarizedDobjCount = 0		// number of dobjs we've summarized
	transcriptDobjCount = 0		// number of dobjs in transcript
	noDistinguisher = nil		// has any summarizer requested to not
					//	use distinguishers

	// Count up some distinguisher-related statistics.
	// The argument is the vector of reports we're summarizing, after
	// we (should have) assigned a summarizer to each of them.
	countSummarizers(lst) {
		local v;

		if(lst == nil)
			return;

		v = new Vector(lst.length);

		lst.forEach(function(o) {
			// Keep track of the direct objects
			o.reports.forEach({ x: v.appendUnique(x.dobj_) });

			// Keep track of the number of summarizers
			if(!o.summarizer.isImplicit)
				summarizers += 1;
		});

		// Remember how many dobjs we counted
		summarizedDobjCount = v.length;

		// Remember how many total dobjs there are associated with
		// the current action
		if(gAction && gAction.dobjList_)
			transcriptDobjCount = gAction.dobjList_.length;
	}

	// Remember how many distinguishers we have.
	// Argument is the vector of non-implicit distinguishers
	// built inside handleSummary()
	countDistinguishers(lst) { distinguishers = lst.length; }

	// Figure out if we're using a distinguisher given all we know.
	check() {
		if(((distinguishers > 1) || (summarizers > 1)
			|| (summarizedDobjCount != transcriptDobjCount)))
			return(true);
		return(nil);
	}

	clear() {
		distinguishers = 0;
		summarizers = 0;
		summarizedDobjCount = 0;
		transcriptDobjCount = 0;
		noDistinguisher = nil;
	}
;
