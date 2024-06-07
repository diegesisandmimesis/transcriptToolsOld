#charset "us-ascii"
//
// testCases.t
// Version 1.0
// Copyright 2022 Diegesis & Mimesis
//
// This is a very simple demonstration "game" for the transcriptTools library.
//
// It can be compiled via the included makefile with
//
//	# t3make -f testCases.t3m
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

function inlineCommand(cmd) {
	return('<b>&gt;<<toString(cmd).toUpper()>></b>');
}

flowerReportManager: ReportManager reportManagerFor = Flower;
+ReportSummary @ExamineAction
	summarize(data) {
		return('It\'s <<data.listNames()>>. ');
	}
;

class Flower: Thing 'flower*flowers' 'flower'
	"A <<color>> flower. "

	isEquivalent = true
	reportName = 'flower'
	color = nil

	initializeThing() {
		setColor();
		inherited();
	}

	setColor() {
		if(color == nil) color = 'colorless';
		cmdDict.addWord(self, color, &adjective);
		name = color + ' flower';
	}
;

class RedFlower: Flower color = 'red';
class BlueFlower: Flower color = 'blue';
class GreenFlower: Flower color = 'green';

class ShortFlower: Thing '(short) flower*flowers' 'flower'
	"A short <<color>> flower. "

	isEquivalent = true
	reportName = 'flower'
	color = nil

	initializeThing() {
		setColor();
		inherited();
	}

	setColor() {
		if(color == nil) color = 'colorless';
		cmdDict.addWord(self, color, &adjective);
		name = 'short ' + color + ' flower';
	}

	dobjFor(Examine) {
		summarize(data) {
			return('It\'s <<data.listNames()>>. ');
		}
	}
;

class RedShortFlower: ShortFlower color = 'red';
class BlueShortFlower: ShortFlower color = 'blue';
class GreenShortFlower: ShortFlower color = 'green';

class TakeToggle: Thing
	takeable = true
	dobjFor(Take) {
		verify() {
			if(takeable != true)
				illogical(&cannotTakeThatMsg);
		}
	}
;

class AlarmItem: Thing
	dobjFor(Take) {
		action() {
			inherited();
			mainReport('As you pick up {a dobj/him}, an alarm sounds
				in the distance. ');
		}

		summarize(data) {
			return('As you pick up the <<data.listNames()>>, an
				alarm sounds in the distance. ');
		}
	}
;

class Pebble: TakeToggle '(small) (round) pebble*pebbles' 'pebble'
	"A small, round pebble. "
	isEquivalent = true
;
class Rock: TakeToggle '(ordinary) rock*rocks' 'rock'
	"An ordinary rock. "
	isEquivalent = true
;
class Stone: AlarmItem, TakeToggle '(unremarkable) stone*stones' 'stone'
	"An unremarkable stone. "
	isEquivalent = true
;

class Box: Container '(wooden) box' 'box'
	"A wooden box. "
	dobjFor(Take) {
		verify() { illogical('{You/He} can\'t take <<theName>>. '); }
	}
;
class Vase: Container '(delicate) vase' 'vase'
	"A delicate vase. "
	dobjFor(Take) {
		action() {
			inherited();
			mainReport('{You/He} gingerly take{s} <<theName>>. ');
		}
	}
;
class Sign: Fixture 'sign' 'sign' "[This space intentionally left blank] ";

Sign template "desc";

centralRoom: Room 'Central Room'
	"This is the central room.  Exits to rooms one through four are
	in the cardinal directions, clockwise from the north. "
	north = roomOne
	east = roomTwo
	south = roomThree
	west = roomFour
;
+me: Person;

roomOne: Room 'Room One'
	"This is room one.  The central room is to the south and
	room 1B is to the north.
	<.p>
	There's a sign on the wall. "
	north = room1B
	south = centralRoom
;
+Sign "If you <<inlineCommand('take all')>> you should get
	a single report for both objects, instead of a report for each. ";
+Pebble;
+Rock;

room1B: Room 'Room 1B'
	"This is room 1B.  Room one is to the south.
	<.p>
	There's a sign on the wall. "
	south = roomOne
;
+Sign "If you <<inlineCommand('take all')>> you should get a single
	failure report for both objects, instead of a separate failure report
	for each one. ";
+Pebble takeable = nil;
+Pebble takeable = nil;
+Rock takeable = nil;

roomTwo: Room 'Room Two'
	"This is room two.  The central room is to the west.
	<.p>
	There's a sign on the wall. "
	west = centralRoom
;
+Sign "If you <<inlineCommand('examine all')>> the flowers should all be
	grouped by their locations instead of their colors. ";
+GreenFlower;
+RedFlower;
+Pebble;
+GreenFlower;
+Box;
++RedFlower;
++Pebble;
++BlueFlower;
++RedFlower;
+GreenFlower;

roomThree: Room 'Room Three'
	"This is room three.  The central room is to the north.
	<.p>
	There's a sign on the wall. "
	north = centralRoom
	south = room3B
;
+Sign "If you <<inlineCommand('put all pebbles in vase')>> you should get both
	an implicit announcement for taking the pebbles and a
	single action summary for all the pebbles put in the vase.
	<.p>
	<<inlineCommand('undo')>> that and then
	<<inlineCommand('take all from box')>> and you should get a single
	action summary.  Now <<inlineCommand('put pebbles on floor')>>
	and you should get an implicit anouncement and an action summary
	(and no extraneous reports). ";
+Pebble;
+Pebble;
+Box;
++Pebble;
++Pebble;
+Vase;

room3B: Room 'Room 3B'
	"This is room 3B.  Room three is to the north, 3C is to the south.
	<.p>
	There's a sign on the wall. "
	north = roomThree
	south = room3C
;
+Sign;
//+Pebble;
//+Pebble;
+Stone;
+Stone;
+Box;

room3C: Room 'Room 3C'
	"This is room 3C.  Room 3B is to the north.
	<.p>
	There's a sign on the wall. "
	north = room3B
;
+Sign;
+Pebble;
+Pebble;
+Stone;
+Stone;
+Box;

roomFour: Room 'Room Four'
	"This is room four.  The central room is to the east.
	<.p>
	There's a sign on the wall. "
	east = centralRoom
;
+Sign "The parent class of the flowers in this room use a self-summarizer.  If
you do a <<inlineCommand('examine flowers')>> you'll get a single summary
report.  The only interesting thing (as opposed to the similar stuff that
happens in room two) is the underlying mechanism used to do the summary. ";
+RedShortFlower;
+GreenShortFlower;
+BlueShortFlower;

modify transcriptTools active = true;
//modify syslog initFlags = 'assignSummarizer';
