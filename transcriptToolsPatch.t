#charset "us-ascii"
//
// transcriptToolsPatch.t
//
//	Modifies all the stock adv3 TAction classes to have a
//	summarizeDobjProp property, required for self-summaries.
//
//	THIS FILE IS GENERATED AUTOMAGICALLY
//
//	Changes shouldn't be made here, but instead to
//	transcriptToolsGenerate.t.  See the comments there for more details.
//
#include <adv3.h>
#include <en_us.h>

#include "transcriptTools.h"

modify StarboardAction summarizeDobjProp = &summarizeDobjStarboard;
modify WestAction summarizeDobjProp = &summarizeDobjWest;
modify PortAction summarizeDobjProp = &summarizeDobjPort;
modify PourAction summarizeDobjProp = &summarizeDobjPour;
modify TurnAction summarizeDobjProp = &summarizeDobjTurn;
modify ListenImplicitAction summarizeDobjProp = &summarizeDobjListenImplicit;
modify PushNorthAction summarizeDobjProp = &summarizeDobjPushNorth;
modify PushSouthAction summarizeDobjProp = &summarizeDobjPushSouth;
modify NortheastAction summarizeDobjProp = &summarizeDobjNortheast;
modify SoutheastAction summarizeDobjProp = &summarizeDobjSoutheast;
modify InventoryAction summarizeDobjProp = &summarizeDobjInventory;
modify NorthwestAction summarizeDobjProp = &summarizeDobjNorthwest;
modify SouthwestAction summarizeDobjProp = &summarizeDobjSouthwest;
modify LieOnAction summarizeDobjProp = &summarizeDobjLieOn;
modify DetachFromAction summarizeDobjProp = &summarizeDobjDetachFrom;
modify LookBehindAction summarizeDobjProp = &summarizeDobjLookBehind;
modify ParseDebugAction summarizeDobjProp = &summarizeDobjParseDebug;
modify CleanAction summarizeDobjProp = &summarizeDobjClean;
modify BreakAction summarizeDobjProp = &summarizeDobjBreak;
modify DebugAction summarizeDobjProp = &summarizeDobjDebug;
modify ClimbAction summarizeDobjProp = &summarizeDobjClimb;
modify BoardAction summarizeDobjProp = &summarizeDobjBoard;
modify OopsIAction summarizeDobjProp = &summarizeDobjOopsI;
modify SitOnAction summarizeDobjProp = &summarizeDobjSitOn;
modify PutInAction summarizeDobjProp = &summarizeDobjPutIn;
modify HelloAction summarizeDobjProp = &summarizeDobjHello;
modify AttackWithAction summarizeDobjProp = &summarizeDobjAttackWith;
modify PutOnAction summarizeDobjProp = &summarizeDobjPutOn;
modify CloseAction summarizeDobjProp = &summarizeDobjClose;
modify LightAction summarizeDobjProp = &summarizeDobjLight;
modify DrinkAction summarizeDobjProp = &summarizeDobjDrink;
modify SleepAction summarizeDobjProp = &summarizeDobjSleep;
modify StandAction summarizeDobjProp = &summarizeDobjStand;
modify SmellAction summarizeDobjProp = &summarizeDobjSmell;
modify EnterAction summarizeDobjProp = &summarizeDobjEnter;
modify TasteAction summarizeDobjProp = &summarizeDobjTaste;
modify ScrewAction summarizeDobjProp = &summarizeDobjScrew;
modify UnlockWithAction summarizeDobjProp = &summarizeDobjUnlockWith;
modify NorthAction summarizeDobjProp = &summarizeDobjNorth;
modify PushTravelEnterAction summarizeDobjProp = &summarizeDobjPushTravelEnter;
modify ExitsAction summarizeDobjProp = &summarizeDobjExits;
modify PushTravelAction summarizeDobjProp = &summarizeDobjPushTravel;
modify UnplugFromAction summarizeDobjProp = &summarizeDobjUnplugFrom;
modify SouthAction summarizeDobjProp = &summarizeDobjSouth;
modify ThrowAction summarizeDobjProp = &summarizeDobjThrow;
modify GoBackAction summarizeDobjProp = &summarizeDobjGoBack;
modify ExtinguishAction summarizeDobjProp = &summarizeDobjExtinguish;
modify DetachAction summarizeDobjProp = &summarizeDobjDetach;
modify LookInAction summarizeDobjProp = &summarizeDobjLookIn;
modify GiveToAction summarizeDobjProp = &summarizeDobjGiveTo;
modify TalkToAction summarizeDobjProp = &summarizeDobjTalkTo;
modify PlugInAction summarizeDobjProp = &summarizeDobjPlugIn;
modify SearchAction summarizeDobjProp = &summarizeDobjSearch;
modify PushInAction summarizeDobjProp = &summarizeDobjPushIn;
modify AttackAction summarizeDobjProp = &summarizeDobjAttack;
modify GetOutAction summarizeDobjProp = &summarizeDobjGetOut;
modify MoveToAction summarizeDobjProp = &summarizeDobjMoveTo;
modify TypeOnAction summarizeDobjProp = &summarizeDobjTypeOn;
modify FastenAction summarizeDobjProp = &summarizeDobjFasten;
modify ShowToAction summarizeDobjProp = &summarizeDobjShowTo;
modify PushUpAction summarizeDobjProp = &summarizeDobjPushUp;
modify TurnOnAction summarizeDobjProp = &summarizeDobjTurnOn;
modify VagueTravelAction summarizeDobjProp = &summarizeDobjVagueTravel;
modify UnlockAction summarizeDobjProp = &summarizeDobjUnlock;
modify RemoveAction summarizeDobjProp = &summarizeDobjRemove;
modify TravelAction summarizeDobjProp = &summarizeDobjTravel;
modify SwitchAction summarizeDobjProp = &summarizeDobjSwitch;
modify FollowAction summarizeDobjProp = &summarizeDobjFollow;
modify LookThroughAction summarizeDobjProp = &summarizeDobjLookThrough;
modify UnplugAction summarizeDobjProp = &summarizeDobjUnplug;
modify UnscrewWithAction summarizeDobjProp = &summarizeDobjUnscrewWith;
modify ClimbUpAction summarizeDobjProp = &summarizeDobjClimbUp;
modify DigWithAction summarizeDobjProp = &summarizeDobjDigWith;
modify PushTravelViaIobjAction summarizeDobjProp = &summarizeDobjPushTravelViaIobj;
modify JumpOffAction summarizeDobjProp = &summarizeDobjJumpOff;
modify StandOnAction summarizeDobjProp = &summarizeDobjStandOn;
modify PushTravelClimbUpAction summarizeDobjProp = &summarizeDobjPushTravelClimbUp;
modify PushAftAction summarizeDobjProp = &summarizeDobjPushAft;
modify TurnOffAction summarizeDobjProp = &summarizeDobjTurnOff;
modify ExamineAction summarizeDobjProp = &summarizeDobjExamine;
modify CutWithAction summarizeDobjProp = &summarizeDobjCutWith;
modify GoodbyeAction summarizeDobjProp = &summarizeDobjGoodbye;
modify ThrowAtAction summarizeDobjProp = &summarizeDobjThrowAt;
modify NoteDarknessAction summarizeDobjProp = &summarizeDobjNoteDarkness;
modify ThrowToAction summarizeDobjProp = &summarizeDobjThrowTo;
modify UnfastenFromAction summarizeDobjProp = &summarizeDobjUnfastenFrom;
modify PushOutAction summarizeDobjProp = &summarizeDobjPushOut;
modify UnscrewAction summarizeDobjProp = &summarizeDobjUnscrew;
modify ConsultAction summarizeDobjProp = &summarizeDobjConsult;
modify PushTravelThroughAction summarizeDobjProp = &summarizeDobjPushTravelThrough;
modify GetOffOfAction summarizeDobjProp = &summarizeDobjGetOffOf;
modify JumpOffIAction summarizeDobjProp = &summarizeDobjJumpOffI;
modify GetOutOfAction summarizeDobjProp = &summarizeDobjGetOutOf;
modify AttachToAction summarizeDobjProp = &summarizeDobjAttachTo;
modify TakeFromAction summarizeDobjProp = &summarizeDobjTakeFrom;
modify PushTravelGetOutOfAction summarizeDobjProp = &summarizeDobjPushTravelGetOutOf;
modify FastenToAction summarizeDobjProp = &summarizeDobjFastenTo;
modify LockWithAction summarizeDobjProp = &summarizeDobjLockWith;
modify PushForeAction summarizeDobjProp = &summarizeDobjPushFore;
modify PushTravelDirAction summarizeDobjProp = &summarizeDobjPushTravelDir;
modify PushEastAction summarizeDobjProp = &summarizeDobjPushEast;
modify ListenToAction summarizeDobjProp = &summarizeDobjListenTo;
modify PlugIntoAction summarizeDobjProp = &summarizeDobjPlugInto;
modify ThrowDirAction summarizeDobjProp = &summarizeDobjThrowDir;
modify MoveWithAction summarizeDobjProp = &summarizeDobjMoveWith;
modify BurnWithAction summarizeDobjProp = &summarizeDobjBurnWith;
modify PutUnderAction summarizeDobjProp = &summarizeDobjPutUnder;
modify SmellImplicitAction summarizeDobjProp = &summarizeDobjSmellImplicit;
modify JumpOverAction summarizeDobjProp = &summarizeDobjJumpOver;
modify PushDownAction summarizeDobjProp = &summarizeDobjPushDown;
modify SenseImplicitAction summarizeDobjProp = &summarizeDobjSenseImplicit;
modify PourIntoAction summarizeDobjProp = &summarizeDobjPourInto;
modify PushStarboardAction summarizeDobjProp = &summarizeDobjPushStarboard;
modify PushWestAction summarizeDobjProp = &summarizeDobjPushWest;
modify UnfastenAction summarizeDobjProp = &summarizeDobjUnfasten;
modify TurnWithAction summarizeDobjProp = &summarizeDobjTurnWith;
modify PushPortAction summarizeDobjProp = &summarizeDobjPushPort;
modify PourOntoAction summarizeDobjProp = &summarizeDobjPourOnto;
modify InventoryWideAction summarizeDobjProp = &summarizeDobjInventoryWide;
modify PushNortheastAction summarizeDobjProp = &summarizeDobjPushNortheast;
modify InventoryTallAction summarizeDobjProp = &summarizeDobjInventoryTall;
modify PushSoutheastAction summarizeDobjProp = &summarizeDobjPushSoutheast;
modify PushNorthwestAction summarizeDobjProp = &summarizeDobjPushNorthwest;
modify PushSouthwestAction summarizeDobjProp = &summarizeDobjPushSouthwest;
modify ReadAction summarizeDobjProp = &summarizeDobjRead;
modify FeelAction summarizeDobjProp = &summarizeDobjFeel;
modify DoffAction summarizeDobjProp = &summarizeDobjDoff;
modify ClimbDownAction summarizeDobjProp = &summarizeDobjClimbDown;
modify CleanWithAction summarizeDobjProp = &summarizeDobjCleanWith;
modify PutBehindAction summarizeDobjProp = &summarizeDobjPutBehind;
modify TakeAction summarizeDobjProp = &summarizeDobjTake;
modify LockAction summarizeDobjProp = &summarizeDobjLock;
modify FlipAction summarizeDobjProp = &summarizeDobjFlip;
modify ForeAction summarizeDobjProp = &summarizeDobjFore;
modify TravelDirAction summarizeDobjProp = &summarizeDobjTravelDir;
modify EastAction summarizeDobjProp = &summarizeDobjEast;
modify PushTravelClimbDownAction summarizeDobjProp = &summarizeDobjPushTravelClimbDown;
modify TravelViaAction summarizeDobjProp = &summarizeDobjTravelVia;
modify WearAction summarizeDobjProp = &summarizeDobjWear;
modify OpenAction summarizeDobjProp = &summarizeDobjOpen;
modify LookUnderAction summarizeDobjProp = &summarizeDobjLookUnder;
modify WaitAction summarizeDobjProp = &summarizeDobjWait;
modify LookAction summarizeDobjProp = &summarizeDobjLook;
modify DropAction summarizeDobjProp = &summarizeDobjDrop;
modify YellAction summarizeDobjProp = &summarizeDobjYell;
modify MoveAction summarizeDobjProp = &summarizeDobjMove;
modify BurnAction summarizeDobjProp = &summarizeDobjBurn;
modify GoThroughAction summarizeDobjProp = &summarizeDobjGoThrough;
modify DownAction summarizeDobjProp = &summarizeDobjDown;
modify KissAction summarizeDobjProp = &summarizeDobjKiss;
modify JumpAction summarizeDobjProp = &summarizeDobjJump;
modify PullAction summarizeDobjProp = &summarizeDobjPull;
modify PushAction summarizeDobjProp = &summarizeDobjPush;
modify ScrewWithAction summarizeDobjProp = &summarizeDobjScrewWith;
modify EventAction summarizeDobjProp = &summarizeDobjEvent;
modify CommandActorAction summarizeDobjProp = &summarizeDobjCommandActor;
modify StrikeAction summarizeDobjProp = &summarizeDobjStrike;
