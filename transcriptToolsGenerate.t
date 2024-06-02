#charset "us-ascii"
//
// transcripToolsGenerate.t
//
//	Code for generating the patch file, transcriptToolsPatch.t.  The
//	patch file tweaks all the TAction classes to include a
//	summarizeDobjProp, which is required to make the
//
//		dobjFor(SomeAction) {
//			summarize(data) { }
//		}
//
//	...logic work.
//
//
//	Compile with -D TRANSCRIPT_TOOLS_GENERATE_PATCH to enable.
//
//	IMPORTANT: DO NOT COMPILE WITH THE -D TRANSCRIPT_TOOLS_GENERATE_PATCH
//		FLAG unless you are building a utility specifically to
//		generate a patch file.  This is NOT code that wants to
//		be included in a released game.
//
#include <adv3.h>
#include <en_us.h>

#include "transcriptTools.h"

#ifdef TRANSCRIPT_TOOLS_GENERATE_PATCH

modify transcriptTools
	_symTbl = nil
	_revSymTbl = nil

	// Entry point for external callers
	generatePatch(fname) {
		local buf;

		buf = new StringBuffer();

		_generateTables();
		_generatePatch(buf);
		if(_stringToFile(buf, fname) == true)
			"\nWrote patch to file <q><<toString(fname)>></q>.\n ";
		else
			"\nFailed to write to file
				<q><<toString(fname)>></q>.\n ";
	}

	// Write a string to a file, with minimal error handling.
	_stringToFile(buf, fname) {
		local log;

		try {
			log = File.openTextFile(fname, FileAccessWrite,
				'utf8');
			log.writeFile(buf);
			log.closeFile();

			return(true);
		}
		catch(Exception e) {
			_error('<<fname>>: File write failed:', e);
			return(nil);
		}
	}

	// Generate a reverse symbol table to speed up lookups
	_generateTables() {
		_symTbl = t3GetGlobalSymbols();
		_revSymTbl = new LookupTable();
		_symTbl.forEachAssoc(function(k, v) {
			_revSymTbl[v] = k;
		});
	}

	// Generate the patch itself.
	_generatePatch(buf) {
		local obj;

		// First, the header bits and some comments.
		buf.append('#charset "us-ascii"\n');
		buf.append('//\n');
		buf.append('// transcriptToolsPatch.t\n');
		buf.append('//\n');
		buf.append('//\tModifies all the stock adv3 TAction classes ');
		buf.append('to have a\n');
		buf.append('//\tsummarizeDobjProp property, required for ');
		buf.append('self-summaries.\n');
		buf.append('//\n');
		buf.append('//\tTHIS FILE IS GENERATED AUTOMAGICALLY\n');
		buf.append('//\n');
		buf.append('//\tChanges shouldn\'t be made here, but instead ');
		buf.append('to\n');
		buf.append('//\ttranscriptToolsGenerate.t.  See the comments ');
		buf.append('there for more details.\n');
		buf.append('//\n');
		buf.append('#include <adv3.h>\n');
		buf.append('#include <en_us.h>\n');
		buf.append('\n');
		buf.append('#include "transcriptTools.h"\n');
		buf.append('\n');

		// Iterate over all TAction instances
		obj = firstObj(TAction, ObjClasses);

		while(obj != nil) {
			_parseObject(buf, obj);
			obj = nextObj(obj, Action, ObjClasses);
		}
	}

	// Generate the patch for a single TAction instance
	_parseObject(buf, obj) {
		local n, n0;

		// Skip a bunch of actions we don't care about
		if(obj.ofKind(SystemAction))
			return;
		if(obj.ofKind(ConvTopicTAction))
			return;
		if(obj.ofKind(LiteralAction) || obj.ofKind(LiteralTAction))
			return;
		if(obj.ofKind(TopicAction) || obj.ofKind(TopicTAction))
			return;

		// If we don't have this object in the symbol table, bail
		if((n = _revSymTbl[obj]) == nil)
			return;

		// We only care about actions of the form [something]Action
		if(!n.endsWith('Action'))
			return;

		// The the base name of the Action, without -'Action'
		n0 = n.findReplace('Action', '');

		// Discard TAction, TIAction, and so on
		if(n0.length < 4)
			return;

		// The patch
		buf.append('modify ');
		buf.append(toString(n));
		buf.append(' summarizeDobjProp = ');
		buf.append('&summarizeDobj');
		buf.append(n0);
		buf.append(';\n');
	}
;

#endif // TRANSCRIPT_TOOLS_GENERATE_PATCH
