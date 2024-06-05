#charset "us-ascii"
//
// distinguisher.t
//
//
#include <adv3.h>
#include <en_us.h>

#include "transcriptTools.h"

// Now we modify the distinguishers.
// We add an "aOrCountName" method to each, which we use for 
modify nullDistinguisher
	canDistinguish(a, b) { return(a.reportName != b.reportName); }
	aOrCountName(obj, n) {
		return((n == 1) ? name(obj) : obj.countName(n));
	}
	singlePluralName(obj, n) {
		return((n == 1) ? name(obj) : obj.pluralName);
	}
	reportName(obj, n) {
		return((n == 1) ? obj.reportName : obj.pluralReportName);
	}
;

modify basicDistinguisher
	canDistinguish(a, b) {
		local na, nb;

		// If the objects aren't equivalent, then we don't have
		// to worry about the equivalence keys.
		if(!(a.isEquivalent && b.isEquivalent))
			return(true);

		// Normal logic is to just compare the equivance keys, but
		// here we check to see if the objects have reportNames
		// that aren't the same as the equivalence keys (which
		// they will be by default) and if so use the reportNames
		// instead
		na = ((a.reportName == a.equivalenceKey) ? a.equivalenceKey
			: a.reportName);
		nb = ((b.reportName == b.equivalenceKey) ? b.equivalenceKey
			: b.reportName);

		return(na != nb);
	}
	aOrCountName(obj, n) {
		return((n == 1) ? name(obj) : obj.countDisambigName(n));
	}
	singlePluralName(obj, n) {
		return((n == 1) ? name(obj) : obj.pluralName);
	}
	reportName(obj, n) {
		return((n == 1) ? obj.reportName : obj.pluralReportName);
	}
;

modify ownershipDistinguisher
	aOrCountName(obj, n) {
		return((n == 1)
			? name(obj) : obj.countNameOwnerLoc(n, true));
	}
	singlePluralName(obj, n) {
		return((n == 1) ? obj.aNameOwnerLoc(true)
			: obj.pluralNameOwnerLoc(true));
	}
	reportName(obj, n) {
		return((n == 1) ? obj.reportNameOwnerLoc(true)
			: obj.pluralReportNameOwnerLoc(true));
	}
;

modify locationDistinguisher
	aOrCountName(obj, n) {
		return((n == 1) ? name(obj) : obj.countNameOwnerLoc(n, nil));
	}
	singlePluralName(obj, n) {
		return((n == 1) ? obj.aNameOwnerLoc(nil)
			: obj.pluralNameOwnerLoc(nil));
	}
	reportName(obj, n) {
		return((n == 1) ? obj.reportNameOwnerLoc(nil)
			: obj.pluralReportNameOwnerLoc(nil));
	}
;

modify litUnlitDistinguisher
	aOrCountName(obj, n) {
		return((n == 1) ? obj.aNameLit : obj.pluralNameLit);
	}
	singlePluralName(obj, n) {
		return((n == 1) ? obj.aNameLit : obj.pluralNameLit);
	}
	reportName(obj, n) {
		return(singlePluralName(obj, n));
	}
;
