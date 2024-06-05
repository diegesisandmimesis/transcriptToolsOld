#charset "us-ascii"
//
// reportName.t
//
//	Modifications to Thing for the reportName property.  The report
//	name is an optional distinguisher that's used only in report
//	summaries.
//
//	The design case for this is when you have multiple "types" of
//	something that want to be individually handled via isEquivalent, but
//	you want report summaries to group them all together.
//
//	For example, if you have red flowers, blue flowers, and green flowers
//	and you want listers to group them by color ("You see two red
//	flowers and three blue flowers here.") but you want report
//	summaries for flowers to all be grouped together.  So
//
//		flowers: [action report]
//
//	...instead of...
//
//		red flowers: [action report]
//		blue flowers: [action report]
//
//
//
#include <adv3.h>
#include <en_us.h>

#include "transcriptTools.h"

modify Thing
	// By default the reportName is just the name
	reportName = name
	pluralReportName = (pluralNameFrom(reportName))

	// The remaining methods below are used by the distinguisher logic

	pluralNameOwnerLoc(ownerPriority) {
		local owner;

		if(((owner = getNominalOwner()) != nil)
			&& (ownerPriority || isDirectlyIn(owner))) {
			return(owner.theNamePossAdj + ' ' + pluralName);
		} else {
			return(location.childInNameWithOwner(pluralName));
		}
	}

	reportNameOwnerLoc(ownerPriority) {
		local owner;

		if(((owner = getNominalOwner()) != nil)
			&& (ownerPriority || isDirectlyIn(owner))) {
			return(owner.theNamePossAdj + ' ' + reportName);
		} else {
			return(location.childInNameWithOwner(reportName));
		}
	}

	pluralReportNameOwnerLoc(ownerPriority) {
		local owner;

		if(((owner = getNominalOwner()) != nil)
			&& (ownerPriority || isDirectlyIn(owner))) {
			return(owner.theNamePossAdj + ' ' + pluralReportName);
		} else {
			return(location.childInNameWithOwner(pluralReportName));
		}
	}
;
