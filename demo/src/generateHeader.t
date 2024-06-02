#charset "us-ascii"
//
// generateHeader.t
// Version 1.0
// Copyright 2022 Diegesis & Mimesis
//
// This is a very simple demonstration "game" for the transcriptTools library.
//
// It can be compiled via the included makefile with
//
//	# t3make -f generateHeader.t3m
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

#ifndef TRANSCRIPT_TOOLS_GENERATE_HEADER
#error "This utility must be compiled with -D TRANSCRIPT_TOOLS_GENERATE_HEADER"
#endif // TRANSCRIPT_TOOLS_GENERATE_HEADER

versionInfo: GameID;
gameMain: GameMainDef
	newGame() {
		transcriptTools.generateHeader('transcriptToolsPatch.t');
	}
;
