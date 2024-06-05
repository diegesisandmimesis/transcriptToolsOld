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

// This to allow us to preserve use of "a" for equivalent objects in
// most listers, while using "the" in action reports when there's only
// one equivalent object in scope.
// So, we can have:
//
//	Boring Room
//	This is a boring room.
//
//	You see a pebble here.
//
//	>TAKE PEBBLE
//	You take the pebble.
//
// ...and then...
//
//	Different Room
//	This is a totally different room.
//
//	You see two pebbles here.
//
//	>TAKE PEBBLE
//	You take a pebble.
//
modify Thing
	equivalentListName() {
		if(isEquivalent &&
			(getInScopeDistinguisher() != nullDistinguisher))
			return(aName);

		return(theName);
	}
;

// Lister than uses "the" for unique-ish objects and "a" for isEquivalent
// objects.
// This is based on the lister provided in combineReports.t, but moves
// the decision logic to Thing and makes it slightly more elaborate.
class EquivalentLister: SimpleLister
	showListItem(obj, options, pov, infoTab) {
		say(obj.equivalentListName);
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
