#charset "us-ascii"
//
// generatePatch.t
// Version 1.0
// Copyright 2022 Diegesis & Mimesis
//
// This is a very simple demonstration "game" for the transcriptTools library.
//
// It can be compiled via the included makefile with
//
//	# t3make -f generatePatch.t3m
//
// ...or the equivalent, depending on what TADS development environment
// you're using.
//
// This "game" is distributed under the MIT License, see LICENSE.txt
// for details.
//
#include <adv3.h>
#include <en_us.h>

#include "transcriptTools.h"

#ifndef TRANSCRIPT_TOOLS_GENERATE_PATCH
#error "This utility must be compiled with -D TRANSCRIPT_TOOLS_GENERATE_PATCH"
#endif // TRANSCRIPT_TOOLS_GENERATE_PATCH

versionInfo: GameID;
gameMain: GameMainDef
	newGame() {
		transcriptTools.generatePatch('transcriptToolsPatch.t');
	}
;
