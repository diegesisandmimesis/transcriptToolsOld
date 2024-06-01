#charset "us-ascii"
//
// transcriptDebug.t
//
#include <adv3.h>
#include <en_us.h>

#include "transcriptTools.h"

#ifdef SYSLOG

modify CommandReport
	syslogID = 'CommandReport'

	getSyslogID() { return(syslogID ? syslogID : toString(self)); }
	_debug(msg, flg?) { syslog.debug(getSyslogID(), msg, flg); }
	_error(msg) { syslog.error(getSyslogID(), msg); }

	_debugReport(tag?) {
		_debug('\t<<toString(self)>>', tag);
		_debug('\t\titer_ = <<toString(iter_)>>', tag);
		_debug('\t\taction = <<toString(action_)>>', tag);
		_debug('\t\tisFailure = <<toString(isFailure)>>', tag);
		_debug('\t\tisActionImplicit = <<toString(isActionImplicit)>>',
			tag);
		if(dobj_)
			_debug('\t\tdobj_ = <<dobj_.name>> @
				<<toString(dobj_.location ? dobj_.location.name
				: nil)>>', tag);
	}
;

modify TranscriptTools
	_debugTranscript(tag?) {
		local t;

		if((t = getTranscript()) == nil) {
			_debug('====NO TRANSCRIPT====', tag);
			return;
		}
		_debug('=====TRANSCRIPT START=====', tag);
		_debug('\ttranscript contains <<toString(t.reports_.length)>>
			reports', tag);
		forEachReport({ x: x._debugReport(tag) });
		_debug('=====TRANSCRIPT END=====', tag);
	}
	runTranscriptTools() {
		_debug('===TRANSCRIPT TOOLS START===', 'transcript');
		_debug('=====TRANSCRIPT BEFORE START=====', 'transcript');
		_debugTranscript('transcript');
		_debug('=====TRANSCRIPT BEFORE END=====', 'transcript');
		inherited();
		_debug('=====TRANSCRIPT AFTER START=====', 'transcript');
		_debugTranscript('transcript');
		_debug('=====TRANSCRIPT AFTER END=====', 'transcript');
		_debug('===TRANSCRIPT TOOLS END===', 'transcript');
	}
;

modify ReportGroup
	_debugGroup() {
		_debug('===REPORT GROUP START===', 'reportGroup');
		_debug('\tgroupID = <<toString(groupID)>>', 'reportGroup');
		_debug('\tisFailure = <<toString(isFailure)>>', 'reportGroup');
		vec.forEach({ x: x._debugReport('reportGroup') });
		_debug('===REPORT GROUP END===', 'reportGroup');
	}
;

#endif // SYSLOG
