#charset "us-ascii"
//
// transcriptGroup.t
//
#include <adv3.h>
#include <en_us.h>

#include "transcriptTools.h"

class ReportGroup: TranscriptToolsObject
	vec = nil
	isFailure = nil
	hasImplicit = nil

	addReport(v) {
		if((v == nil) || !v.ofKind(CommandReport))
			return(nil);

		if(vec == nil)
			vec = new Vector(gTranscript.reports_.length);
		vec.appendUnique(v);

		if(v.isFailure == true)
			isFailure = true;

		if(v.isActionImplicit())
			hasImplicit = true;

		return(true);
	}

	getReports() { return(vec); }

	showReports() {
		if(vec == nil)
			return;
		vec.forEach(function(o) {
			_debug('\t<<toString(o)>>');
			_debug('\t\taction = <<toString(o.action_)>>');
			_debug('\t\tisFailure = <<toString(o.isFailure)>>');
			if(o.dobj_) {
				if(o.dobj_.location)
					_debug('\t\tdobj_ = <<o.dobj_.name>>
						@ <<o.dobj_.location.name>>');
				else
					_debug('\t\tdobj_ = <<o.dobj_.name>>');
			}
		});
	}
;
