#charset "us-ascii"
//
// transcriptLister.t
//
//	A couple listers used by the module
//
//
#include <adv3.h>
#include <en_us.h>

#include "transcriptTools.h"

// Lister than uses "the" for unique-ish objects and "a" for isEquivalent
// objects.
// Same behavior as the lister provided by combineReports.t
class EquivalentLister: SimpleLister
	showListItem(obj, options, pov, infoTab) {
		say(obj.isEquivalent ? obj.aName : obj.theName);
	}
;

// A lister that uses "or" instead of "and" as its conjunction.
// Mostly used for failures (to give "You can't take the apple or the orange"
// instead of "You can't take the apple and the orange")
class OrLister: SimpleLister
	listSepTwo = " or "
	listSepEnd = ", or "
	longListSepTo = ", or "
	longListSepEnd = "; or "
;

// Instances of the above classes
equivalentLister: EquivalentLister;
equivalentOrLister: EquivalentLister, OrLister;
