#charset "us-ascii"
//
// flowerTest.t
// Version 1.0
// Copyright 2022 Diegesis & Mimesis
//
// This is a very simple demonstration "game" for the transcriptTools library.
//
// It can be compiled via the included makefile with
//
//	# t3make -f flowerTest.t3m
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

// Our report manager.  All it does is summarize the >EXAMINE command on
// the flowers.
flowerReportManager: ReportManager
	reportManagerFor = Flower
;
+ReportSummary @ExamineAction
	// Summarize the examines.
	summarize(data) {
		return('It\'s <<objectLister.makeSimpleList(data.objs)>>. ');
	}
;
+ReportSummary @SmellAction
	summarize(data) { return('They all smell the same. '); }
;

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
;

class RedFlower: Flower color = 'red';
class BlueFlower: Flower color = 'blue';
class GreenFlower: Flower color = 'green';

class Pebble: Thing '(small) (round) pebble*pebbles' 'pebble'
	"A small, round pebble. "
	isEquivalent = true;

startRoom: Room 'Void' "This is a featureless void.";
+me: Person;
// A bunch of flower instances with some other stuff in the middle.
++GreenFlower;
++Pebble;
++RedFlower;
+GreenFlower;
+RedFlower;
+Pebble;
+GreenFlower;
+box: Container '(wooden) box' 'box' "A wooden box. ";
++RedFlower;
++Pebble;
++BlueFlower;
++RedFlower;
//+BlueFlower;
+GreenFlower;

modify syslog initFlags = 'transcript';

/*
modify Thing
	getBestDistinguisher(lst) {
		local bestDist, bestCnt;

		lst -= self;

        if(lst.subset({obj: !nullDistinguisher.canDistinguish(self, obj)}).length() == 0) {
aioSay('\nnull distinguisher\n ');
lst.forEach(function(o) {
	aioSay('\n\t<<o.name>>\n ');
});
            return nullDistinguisher;
	}

        lst = lst.subset(
            {obj: !basicDistinguisher.canDistinguish(self, obj)});

        if (lst.length() == 0) {
aioSay('\nbasic distinguisher\n ');
            return basicDistinguisher;
}

        bestDist = basicDistinguisher;
        bestCnt = lst.countWhich({obj: bestDist.canDistinguish(self, obj)});

        foreach (local dist in distinguishers) {
            if (dist == bestDist)
                continue;

            local cnt = lst.countWhich({obj: dist.canDistinguish(self, obj)});

            if (cnt == lst.length())
                return dist;

            if (cnt > bestCnt) {
                bestDist = dist;
                bestCnt = cnt;
            }
        }

aioSay('\nbest distinguisher\n ');
        return bestDist;
	}
;
*/
