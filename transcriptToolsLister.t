#charset "us-ascii"
//
// transcriptLister.t
//
#include <adv3.h>
#include <en_us.h>

#include "transcriptTools.h"

class EquivalentLister: SimpleLister
	showListItem(obj, options, pov, infoTab) {
		say(obj.isEquivalent ? obj.aName : obj.theName);
	}
;

class OrLister: SimpleLister
	listSepTwo = " or "
	listSepEnd = ", or "
	longListSepTo = ", or "
	longListSepEnd = "; or "
;

equivalentLister: EquivalentLister;

equivalentOrLister: EquivalentLister, OrLister;
