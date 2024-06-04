#charset "us-ascii"
//
// transcriptToolsConjugation.t
//
//	Conjugations for irregular verbs used by the default report
//	summaries.
//
//
#include <adv3.h>
#include <en_us.h>

#include "transcriptTools.h"

modify TakeAction conjugation = '{take[s]|took}';
modify TakeFromAction conjugation = '{take[s]|took}';
modify DropAction conjugation = 'drop{s/ped}';
modify PutOnAction conjugation = '{put[s]|put}';
modify PutInAction conjugation = '{put[s]|put}';
modify PutUnderAction conjugation = '{put[s]|put}';
modify PutBehindAction conjugation = '{put[s]|put}';
