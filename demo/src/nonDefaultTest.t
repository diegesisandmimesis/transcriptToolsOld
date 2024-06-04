#charset "us-ascii"
//
// nonDefaultTest.t
// Version 1.0
// Copyright 2022 Diegesis & Mimesis
//
// This is a very simple demonstration "game" for the transcriptTools library.
//
// It can be compiled via the included makefile with
//
//	# t3make -f nonDefaultTest.t3m
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

versionInfo: GameID;
gameMain: GameMainDef initialPlayerChar = me;

class Pebble: Thing '(small) (round) pebble*pebbles' 'pebble'
	"A small, round pebble. "
	isEquivalent = true
	dobjFor(Take) {
		action() {
			inherited();
			mainReport('{You/He} carefully obtain{s} the pebble. ');
		}
	}
;

startRoom: Room 'Void' "This is a featureless void.";
+me: Person;
+Pebble;
+Pebble;
+Container '(wooden) box' 'box' "A wooden box. "
	dobjFor(Take) {
		verify() { illogical('{You/He} can\'t take the box. '); }
	}
;
++Pebble;
++Pebble;

modify transcriptTools active = true;
//modify syslog initFlags = 'transcript';
