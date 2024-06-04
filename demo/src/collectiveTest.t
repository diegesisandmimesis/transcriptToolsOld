#charset "us-ascii"
//
// collectiveTest.t
// Version 1.0
// Copyright 2022 Diegesis & Mimesis
//
// This is a very simple demonstration "game" for the transcriptTools library.
//
// It can be compiled via the included makefile with
//
//	# t3make -f collectiveTest.t3m
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

	collectiveGroup = [ pebbleCollective ]
	listWith = [ pebbleList ]
;
pebbleList: ListGroupEquivalent;
pebbleCollective: CollectiveGroup 'pebbles' 'pebbles'
	"A bunch of pebbles. "
	isPlural = true
	isCollectiveAction(action, whichObj) { return(true); }
;

startRoom: Room 'Void' "This is a featureless void.";
+me: Person;
+Pebble;
+Pebble;
+Pebble;

//modify syslog initFlags = 'reportGroup';
//modify transcriptTools active = true;
