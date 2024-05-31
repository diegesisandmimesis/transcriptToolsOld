#charset "us-ascii"
//
// transcriptToolsReportManager.t
//
//
#include <adv3.h>
#include <en_us.h>

#include "transcriptTools.h"

class SummarizerData: object
	summarizer = nil
	reports = perInstance(new Vector())

	construct(s) { summarizer = s; }
;

class DistinguisherData: object
	distinguisher = nil
	reports = perInstance(new Vector())

	construct(d) { distinguisher = d; }
;

class TranscriptReportManager: TranscriptTool
	toolPriority = 500

	defaultReportManagers = static [ GeneralReportManager ]
	_reportManagers = nil

	_timestamp = nil
	_distinguisherFlag = nil

	getReportManager(cls) {
		local i;

		if(_reportManagers == nil)
			return(nil);

		for(i = 1; i <= _reportManagers.length; i++) {
			if(_reportManagers[i].ofKind(cls))
				return(_reportManagers[i]);
		}

		return(nil);
	}

	initializeTranscriptTool() {
		inherited();
		addDefaultReportManagers();
	}

	addReportManager(obj) {
		if(_reportManagers == nil)
			_reportManagers = new Vector();
		_reportManagers.append(obj);
	}

	addDefaultReportManagers() {
		local obj;

		if(defaultReportManagers == nil)
			return;
		if(!defaultReportManagers.ofKind(Collection))
			defaultReportManagers = [ defaultReportManagers ];

		defaultReportManagers.forEach(function(o) {
			if(getReportManager(o))
				return;
			obj = o.createInstance();
			obj.location = self;
			obj.initializeReportManager();
			addReportManager(obj);
		});
	}

	getDistinguisherFlag() { return(_distinguisherFlag == true); }
	setDistinguisherFlag() { _distinguisherFlag = true; }

	run() {
		local t, vec;

		if(_timestamp == gTurn)
			return;
		_timestamp = gTurn;

		_distinguisherFlag = nil;

		if((t = getTranscript()) == nil)
			return;

		// Get a list of all the reports we want to summarize,
		// grouped by the summarizer that wants to summarize them.
		vec = assignSummarizers();

		// Got nuthin, got nuthin to do
		if(vec.length < 1)
			return;

		// If we have more than one bunch of reports to summarize,
		// we'll use distinguishers to distinguish them.
		if(vec.length > 1)
			setDistinguisherFlag();

		if(getTotalDobjCount() != getSummarizedDobjCount(vec))
			setDistinguisherFlag();

		vec.forEach({ x: handleSummary(x, t) });
	}

	getTotalDobjCount() {
		return((gAction && gAction.dobjList_)
			? gAction.dobjList_.length : 0);
	}

	getSummarizedDobjCount(vec) {
		local n;

		n = 0;
		vec.forEach({ x: n += x.reports.length });
		return(n);
	}

	// Figure out if anyone wants to summarize this report
	assignSummarizer(report) {
		local r;

		if((r = report.getReportSummarizer()) != nil)
			return(r);

		r = getReportSummarizer(report);

		return(r);
	}

	getReportSummarizer(report) {
		local i, r;

		if(_reportManagers == nil)
			return(nil);

		for(i = 1; i <= _reportManagers.length; i++) {
			if((r = _reportManagers[i].getReportSummarizer(report))
				!= nil)
				return(r);
		}

		return(nil);
	}

	assignSummarizers() {
		local o, s, vec;

		vec = new Vector(8);

		// Go through the list of reports, checking to see if
		// there's a summarizer that wants to summarize it.
		forEachReport(function(report) {
			// No summarizer, nothing to do
			if((s = assignSummarizer(report)) == nil)
				return;

			// If we haven't seen this summarizer before,
			// create a new summary data object for it
			if((o = vec.valWhich({
				x: x.summarizer == s
			})) == nil) {
				vec.append(new SummarizerData(s));
				o = vec[vec.length];
			}

			// Add this report to the reports for this summarizer
			o.reports.append(report);
		});

		return(vec);
	}

	// First arg is a SummarizerData instance, second is the transcript
	// we're working on
	handleSummary(data, t) {
		local dist, o, vec;

		vec = new Vector();

		// Go through all the reports for this summarizer
		data.reports.forEach(function(report) {
			// Get the distinguisher for this report
			dist = getReportDistinguisher(report.dobj_, 1);

//aioSay('\n\tdistinguisher = <<toString(dist)>> for <<report.dobj_.name>> @ <<report.dobj_.location.name>>\n ');
			// If we haven't seen this distinguisher before,
			// create a new distinguisher data object for
			// it
			if((o = vec.valWhich({
				x: x.distinguisher == dist
			})) == nil) {
				vec.append(new DistinguisherData(dist));
				o = vec[vec.length];
			}

			// Add this report to the reports for this
			// distinguisher
			o.reports.append(report);
		});

		// If we have more than one distinguisher's worth of
		// reports, we (obviously) want to use them
		if(vec.length > 1)
			setDistinguisherFlag();

		vec.forEach({ x: _handleSummary(data.summarizer, x, t) });
	}

	_handleSummary(summarizer, data, t) {
		local d, r;

		d = new ReportSummaryData(data.reports);
		r = createSummaryReport(d, summarizer.summarize(d));
		replaceReports(data.reports, r);
	}

	createSummaryReport(data, msg, dist?) {
		local txt;

		txt = new StringBuffer();

		if(getDistinguisherFlag() == true) {
			if(dist == nil)
				dist = getReportDistinguisher(data.dobj,
					data.vec.length);
			txt.append('<./p0>\n<.announceObj>');
			txt.append(dist);
			txt.append(':<./announceObj> <.p0>');
		}
		txt.append(msg);

		return(new CommandReportSummary(toString(txt)));
	}

	getReportDistinguisher(obj, n) {
		if(obj == nil)
			return(nil);

		if(obj.reportManager
			&& obj.reportManager.reportManagerAnnounceText)
			return(obj.reportManager.reportManagerAnnounceText);

//local d = obj.getBestDistinguisher(gAction.getResolvedObjList(DirectObject));
//aioSay('\n<<obj.name>> using <<toString(d)>>\n ');
		return(obj.getBestDistinguisher(gAction
			.getResolvedObjList(DirectObject))
			.reportName(obj, n));
	}
;
