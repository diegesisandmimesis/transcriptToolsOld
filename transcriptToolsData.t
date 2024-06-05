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
