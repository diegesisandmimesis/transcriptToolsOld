#charset "us-ascii"
//
// transcriptToolsData.t
//
//
//
#include <adv3.h>
#include <en_us.h>

#include "transcriptTools.h"

// Data structure for holding the reports for a specific summarizer.
// Normal flow is to go through the transcript and see which reports
// want to be handled by which summarizers.  The result of that
// process is a vector of instances of SummarizerData.
class SummarizerData: object
	// The summarizer, i.e. an instance of ReportSummary
	summarizer = nil

	// The reports to be passed to the summarizer above
	reports = perInstance(new Vector())

	construct(s) { summarizer = s; }
;

// Data structure for holding the reports for a specific distinguisher
// announcement
// In the normal flow of processing the reports for each summarizer (as
// organized into SummarizerData instances, above) are iterated through,
// determining what object distinguisher announcement, if any, is needed
// for disambiguation in the report.  In this case the distinguisher
// is the noun phrase before the colon in the output.
// We also use DistinguisherData to aggregate implicit reports, in that
// case using their action as "distinguisher".
class DistinguisherData: object
	// The distinguisher text
	distinguisher = nil

	// Vector of reports sharing the distinguisher above
	reports = perInstance(new Vector())

	construct(d) { distinguisher = d; }
;

// Data structure passed to ReportSummary.summarize()
class ReportSummaryData: object
	// Vector of reports to be summarized
	vec = nil

	// Vector of objects from the reports
	objs = nil

	// Number of direct objects in the summary.  By default
	// the length of objs, above
	count = nil

	// "Representative" dobj and iobj from the reports.  Mostly makes
	// sense if we're summarizing a bunch of isEquivalent objects.
	// Just used to get vocabulary, mostly.
	dobj = nil
	iobj = nil

	// "Representative" action for the summary.  As above, mostly
	// just for getting vocabulary.
	action = nil

	construct(v) {
		vec = v;

		// If we don't have at least one report, something's
		// borked
		if((v == nil) || (v.length < 1))
			return;

		// If there's a global iobj, remember it.
		// The assumption here is that the summaries involving
		// both dobjs and iobjs might have a lot of dobjs but
		// seldom have more than one iobjs:  >TAKE ALL FROM BOX
		// is common enough, but >TAKE PEBBLE FROM ALL BOXES
		// is unlikely
		if(gIobj != nil)
			iobj = gIobj;

		objs = new Vector(v.length);
		vec.forEach(function(o) {
			if((action == nil) && o.action_ != nil)
				action = o.action_;
			objs.appendUnique(o.dobj_);
		});

		count = objs.length;

		if(objs.length < 1)
			return;

		dobj = objs[1];
		if(dobj)
			dobj._reportCount = count;
	}

	// Convenience methods for listing all our direct objects
	listNames() { return(equivalentLister.makeSimpleList(objs)); }
	listNamesWithAnd() { return(listNames()); }
	listNamesWithOr() { return(equivalentOrLister.makeSimpleList(objs)); }

	// Return the name of our iobj if we have one, nil otherwise.
	// Used in the action clause methods below
	listIobj() { return(iobj ? iobj.theName : nil); }

	// Returns the action.
	// In most cases it'll just be the action we determined in the
	// constructor, but in a few cases (like when >TAKE FROM gets
	// remapped to >TAKE) we have to do some tap-dancing
	getAction() {
		// If we don't have an indirect object, just run with
		// whatever action we got from the constructor
		if(iobj == nil)
			return(action);

		// If we have an indirect object, check to see if our
		// action is a TIAction.  If not, shuffle through the
		// report vector looking for one
		if(!action.ofKind(TIAction))
			vec.forEach(function(o) {
				if(o.action_ && o.action_.ofKind(TIAction))
					action = o.action_;
			});

		return(action);
	}

	// "Action clause" methods.  These should return the
	// correctly-conjugated verb phrase along with the direct and
	// indirect objects.  The "and" and "or" versions use the given
	// conjunction.  "And" is usually for successful reports:
	// (you) "take the pebble and the rock from the box", for example.
	// "Or" is usually for failure reports:  (you can't) "take the
	// pebble or the rock from the box"
	actionClause() {
		return(getAction().actionClause(listNames(), listIobj()));
	}
	actionClauseWithAnd() { return(actionClause()); }
	actionClauseWithOr() {
		return(getAction().actionClause(listNamesWithOr(), listIobj()));
	}
;
