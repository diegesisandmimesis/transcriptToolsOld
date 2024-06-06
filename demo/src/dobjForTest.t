#charset "us-ascii"
//
// dobjForTest.t
// Version 1.0
// Copyright 2022 Diegesis & Mimesis
//
// This is a very simple demonstration "game" for the transcriptTools library.
//
// It can be compiled via the included makefile with
//
//	# t3make -f dobjForTest.t3m
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

// A class for the objects we're going to summarize.
// The only interesting thing about the class is that the objects are
// identical except for their color.
class Flower: Thing 'flower*flowers' 'flower'
	"A <<color>> flower. "

	// The color property.  Needs to be a single-quoted string.
	color = nil

	isEquivalent = true
	reportName = 'flower'

	// Set up each Flower instance at the start of the game.  We need to
	// do this to handle the per-color vocabulary.
	initializeThing() {
		// Important:  setColor() has to happen before the rest
		// 	of initializeThing() OR initializeEquivalent() 
		//	has to be called after.
		setColor();
		inherited();
	}

	// Tweak the vocabulary to reflect the flower's color.
	setColor() {
		if(color == nil)
			color = 'colorless';
		cmdDict.addWord(self, color, &adjective);
		name = '<<color>> flower';
	}

	dobjFor(Examine) {
		summarize(data) { return('It\'s <<data.listNames()>>. '); }
	}
;

class RedFlower: Flower color = 'red';
class BlueFlower: Flower color = 'blue';
class GreenFlower: Flower color = 'green';

startRoom: Room 'Void' "This is a featureless void.";
+me: Person;
+RedFlower;
+BlueFlower;
+GreenFlower;

modify transcriptTools active = true;
//modify syslog initFlags = 'transcript';
