#charset "us-ascii"
//
// reportSummary.t
//
//	Definitions of report summary classes.  This is where the
//	the actual summary logic goes.
//
//	Each ReportSummary instance needs to have a summarize() method
//	that accepts a ReportSummaryData instance as its argument and
//	which returns a text string (the summary text).
//
#include <adv3.h>
#include <en_us.h>

#include "transcriptTools.h"

class CommandReportSummary: MainCommandReport;

class ReportSummary: TranscriptToolsObject
	active = true		// is this summarizer active

	action = nil		// action being summarized
	isFailure = nil		// are we summarizing a failed action?
	isImplicit = nil	// are we summarizing an implicit action?

	reportManager = nil	// our parent report manager

	// The summary class to use
	commandReportSummaryClass = CommandReportSummary

	getActive() { return(active == true); }
	setActive(v) { active = (v ? true : nil); }

	initializeReportSummary() {
		if(location == nil)
			return(nil);

		if(location.ofKind(ReportManager)) {
			location.addReportManagerSummary(self);
			return(true);
		}

		return(nil);
	}

	// Returns boolean true if the given action matches our action
	matchAction(act) {
		if(!getActive())
			return(nil);

		if((act == nil) || (action == nil))
			return(nil);

		return(act.ofKind(action));
	}

	// Method to check to see if we want to accept the report group.
	// This is mostly for ActionSummary, where we do some juggling to
	// handle action re-mapping and use this to have a summarizer
	// for TakeAction reject the group if the gAction is TakeFromAction
	// (because TakeFromAction will end up remapped to TakeAction,
	// so any transcript involving a >TAKE FROM command will contain
	// TakeAction reports...so if we want them to be handled by the
	// TakeFromAction summarizer (instead of the TakeAction summarizer)
	// we have to have some way of pre-empting acceptReport() below.
	// All that nonsense being said, in MOST cases we do nothing
	// here, and leave it all to acceptReport()
	acceptGroup(grp) { return(getActive()); }

	// Decided whether or no we want to summarize this report
	acceptReport(report) {
		if(!getActive())
			return(nil);

		if(report == nil)
			return(nil);

		if(!matchAction(report.action_))
			return(nil);

		if(report.isFailure != isFailure)
			return(nil);

		if(report.isActionImplicit() != isImplicit)
			return(nil);

		return(true);
	}

	// Wrapper for the summarize() method
	_summarize(data) {
		reportSummaryMessageParams(data.dobj);
		return(summarize(data));
	}

	summarize(data) {}

	// Stub for when we want to set up message parameter substitutions
	// for the report summary
	reportSummaryMessageParams(obj?) {}

	checkData(data) {
		if((data == nil) || (data.reports == nil))
			return(nil);
		if(reportManager == nil)
			return(nil);
		return(data.reports.length >= reportManager.minSummaryLength);
	}
/*
	cleanupReports(action) {
		local v;

		v = new Vector();
		forEachReport(function(o) {
			if(o.action_ && o.action_.ofKind(action))
				v.append(o);
		});
		v.forEach({ x: removeReport(x) });
	}
*/

	getTranscript() { return(reportManager.parentTools.getTranscript()); }
	forEachReport(fn) { reportManager.parentTools.forEachReport(fn); }
	removeReport(r) { reportManager.parentTools.removeReport(r); }
;

// Class for failure summaries
class FailureSummary: ReportSummary isFailure = true;

// Class for group-by-action report summaries, a la combineReports.t
class ActionSummary: ReportSummary
	// By default, we prefer to use no distinguishers even when
	// we're summarizing a bunch of different objects types
	noDistinguisher = true

	// The include and exclude properties are for handling
	// action remappings.  See TakeSummary and TakeFromSummary
	// for examples.  Basically whenever you have an action
	// remapping (like TakeFromAction being remapped to TakeAction),
	// the summary for the action mapped TO needs to have a
	// gActionExclude for what it was mapped FROM, and the summary
	// for the action mapped FROM needs to have an actionInclude
	// for what it is mapped TO.  This is so, in this example,
	// TakeSummary doesn't try to summarize the remapped TakeAction
	// reports in the transcript for a >TAKE FROM command, and
	// TakeFromSummary DOES need to grab the TakeAction reports
	// even though it normally wouldn't
	gActionExclude = nil
	actionInclude = nil

	// If non-nil, we'll only match reports whose messageProp_
	// matches matchMessageProp.
	// This is to avoid clobbering bespoke action responses.  If,
	// for example, pebble.dobjFor(Take) has an action() method
	// that sets off an alarm when the player takes the pebble, then
	// we DON'T want that to get squashed by the summarizer.  So
	// we put matchMessageProp = &okayTakeMsg on TakeSummary, and
	// then it'll only summarize TakeAction reports using the
	// default message text
	matchMessageProp = nil
	matchMessageProps = nil

	_skippedReports = nil

	// Logic for checking the matchMessageProp property
	acceptGroup(grp) {
		if((matchMessageProp != nil) && !checkMessageProp(grp)) {
			return(nil);
		}

		return(inherited(grp));
	}

	checkMessageProp(grp) {
		local i, r, v;

		// Make sure we have a property to check
		if((matchMessageProp == nil) && (matchMessageProps == nil))
			return(nil);

		// Get all the reports we accept from the group
		v = new Vector();
		grp.forEachReport(function(o) {
			if(acceptReport(o))
				v.append(o);
		});

		// Go through the accepted reports and figure out
		// which one would actually be used:  a default report
		// if there's no full report, or a full report if one
		// exists
		r = nil;
		v.forEach(function(o) {
			if((r == nil) && o.ofKind(DefaultCommandReport))
				r = o;
			else if(o.ofKind(FullCommandReport))
				r = o;
		});

		// If we didn't get a report, bail
		if(r == nil)
			return(nil);

		// We got a report, so see if its message prop matches
		// the one we're looking for
		if(matchMessageProps != nil) {
			for(i = 1; i <= matchMessageProps.length; i++) {
				if(r.messageProp_ == matchMessageProps[i])
					return(true);
			}
		} else {
			if(r.messageProp_ == matchMessageProp)
				return(true);
		}
		_addSkippedReport(r);
		return(nil);
	}

	_addSkippedReport(report) {
		if(_skippedReports == nil)
			_skippedReports = new Vector();
		_skippedReports.append(report);
	}

	// Additional logic for included and excluded actions
	matchAction(act) {
		// If we have an excluded gAction, see if the current gAction
		// matches it
		if((gActionExclude != nil) && gAction.ofAnyKind(gActionExclude))
			return(nil);

		// If the base matchAction() logic matches the action,
		// cool, we don't have to check anything else
		if(inherited(act) == true)
			return(true);

		// If we're checking actionInclude, we only want to match
		// if the gAction is our action (that is, if we're
		// TakeFromSummary, we only want to continue if gAction
		// is TakeFromAction)
		if(!gAction.ofAnyKind(action))
			return(nil);

		// Now we see if the current action, which we wouldn't
		// otherwise accept, is our actionInclude.  That
		// is, if we're TakeFromSummary, we're checking to see
		// if we're processing a >TAKE FROM command (the gAction
		// check above) and the current report we're checking is
		// a TakeAction report (our actionInclude)
		return((actionInclude != nil) && act.ofAnyKind(actionInclude));
	}

	// Generic action summary
	summarize(data) { return('{You/He} <<data.actionClause()>>.</.p>'); }
;

class ActionFailureSummary: ActionSummary, FailureSummary
	summarize(data) {
		return('<.p>{You/He} can\'t '
			+ '<<data.actionClauseWithOr()>>.</.p>');
	}
;

// Class for implicit action summaries
class ImplicitSummary: ActionSummary
	isImplicit = true

	acceptGroup(grp) {
		// Checking the message prop populates the
		// _skippedReports vector, which we'll later use to
		// re-add any non-default reports after the implicit
		// summary.
		checkMessageProp(grp);

		// We can't use inherited() because ActionSummary does
		// its own message prop checking
		return(getActive());
	}
;

