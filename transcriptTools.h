//
// transcriptTools.h
//

#include "syslog.h"
#ifndef SYSLOG_H
#error "This module requires the syslog module."
#error "https://github.com/diegesisandmimesis/syslog"
#error "It should be in the same parent directory as this module.  So if"
#error "transcriptTools is in /home/user/tads/transcriptTools, then"
#error "syslog should be in /home/user/tads/syslog ."
#endif // SYSLOG_H

#define gIsReport(r) (((r != nil) && r.ofKind(CommandReport)) ? true : nil)
#define gReportObject(r) (gIsReport(r) ? r.dobj_ : nil)
#define gReportObjectOfKind(r, cls) \
	(gIsReport(r) ? (r.dobj_ ? r.dobj_.ofKind(cls) : nil) : nil)
#define gReportAction(r) (gIsReport(r) ? r.action_ : nil)

// Define a macro for the turn number
#ifndef gTurn
#define gTurn (libGlobal.totalTurns)
#endif // gTurn

// Patches for action definition macros.
// Identical to stock plus the summarizeDobjProp property
#undef DefineTActionSub
#define DefineTActionSub(name, cls) \
	DefineAction(name, cls) \
	verDobjProp = &verifyDobj##name \
	remapDobjProp = &remapDobj##name \
	preCondDobjProp = &preCondDobj##name \
	checkDobjProp = &checkDobj##name \
	actionDobjProp  = &actionDobj##name \
	summarizeDobjProp = &summarizeDobj##name \

#undef DefineTIActionSub
#define DefineTIActionSub(name, cls) \
	DefineAction(name, cls) \
	verDobjProp = &verifyDobj##name \
	verIobjProp = &verifyIobj##name \
	remapDobjProp = &remapDobj##name \
	remapIobjProp = &remapIobj##name \
	preCondDobjProp = &preCondDobj##name \
	preCondIobjProp = &preCondIobj##name \
	checkDobjProp = &checkDobj##name \
	checkIobjProp = &checkIobj##name \
	actionDobjProp  = &actionDobj##name \
	actionIobjProp = &actionIobj##name \
	summarizeDobjProp = &summarizeDobj##name

ReportSummary template @action;

#define TRANSCRIPT_TOOLS_H
