#charset "us-ascii"
//
// sample.t
// Version 1.0
// Copyright 2022 Diegesis & Mimesis
//
// This is a very simple demonstration "game" for the transcriptTools library.
//
// It can be compiled via the included makefile with
//
//	# t3make -f makefile.t3m
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

class Flower: Thing 'flower*flowers' 'flower'
	"A <<color>> flower. "

	color = nil
	isEquivalent = true
	reportName = 'flower'

	initializeThing() {
		setColor();
		inherited();
	}

	setColor() {
		if(color == nil)
			color = 'colorless';
		cmdDict.addWord(self, color, &adjective);
		name = '<<color>> flower';
	}

	dobjFor(Take) {
		verify() {
			illogical('{You/He} can\'t pick the flowers. ');
		}
	}
;

class RedFlower: Flower color = 'red';
class BlueFlower: Flower color = 'blue';
class GreenFlower: Flower color = 'green';

class Pebble: Thing '(small) (round) pebble*pebbles' 'pebble'
	"A small, round pebble. "
	isEquivalent = true
;

startRoom: Room 'Void' "This is a featureless void.";
+me: Person;
// A bunch of flower instances with some other stuff in the middle.
+RedFlower;
+Pebble;
+BlueFlower;
+Pebble;
+GreenFlower;
+Container '(wooden) box' 'box' "A wooden box. "
	dobjFor(Take) {
		verify() { illogical('{You/He} can\'t take the box. '); }
	}
;

modify syslog initFlags = 'reportGroup';
modify transcriptTools active = true;
