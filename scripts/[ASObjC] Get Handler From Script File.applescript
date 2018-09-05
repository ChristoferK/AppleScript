#!/usr/bin/osascript
--------------------------------------------------------------------------------
###[ASObjC] Get Handler From Script File.applescript
#
#	An AppleScriptObjC version of Get Handler From Script File.applescript
#
#	Given an AppleScript file (text) containing handler definitions, the
#	script will retrieve a list of handlers by name and present a list from
#	which the user can select.  The chosen handler is then read for text
#	content, copied to the clipboard, and pasted into Script Editor (if
#	running).
#
#  Input:
#	％input％		Either a single value or pair of values: the
#				first is always a filepath to the .applescript
#				file; if it's the only parameter, the script
#				progresses normally.  If the second parameter is
#				⟨missing value⟩, then the list of handlers is
#				returned as text, one per line.  Finally, a
#				string value for the second parameter will be
#				the name of the handler to fetch.
#
#  Result:
#	❮Text❯			Handler source code copied to clipboard and
#				pasted into Script Editor (if running)
--------------------------------------------------------------------------------
#  Author: CK
#  Date Created: 2018-08-22
#  Date Last Edited: 2018-09-05
--------------------------------------------------------------------------------
use framework "Foundation"
use scripting additions

property this : a reference to current application
property NSArray : a reference to NSArray of this
property NSRegularExpression : a reference to NSRegularExpression of this
property NSRegularExpressionCaseInsensitive : a reference to 1
property NSRegularExpressionDotMatchesLineSeparators : a reference to 8
property NSRegularExpressionAnchorsMatchLines : a reference to 16
property NSMutableArray : a reference to NSMutableArray of this
property NSString : a reference to NSString of this
property NSURL : a reference to NSURL of this
property NSUTF16 : a reference to 10
property NSUTF16LE : a reference to NSUTF16LittleEndianStringEncoding of this
--------------------------------------------------------------------------------
property text item delimiters : {linefeed, "/"}
property editor : application "Script Editor"
--------------------------------------------------------------------------------
###IMPLEMENTATION
#
#
on run input
	set [fp, H] to the input & {null}
	if fp's class = script then set fp to (path to fp)'s POSIX path
	
	script handlerList
		property OK : ["Copy", "Paste"]
		property i : a reference to (editor's running as integer)
		property action : OK's item (1 + i)
		property handlerArray : handlersByName from fp
		
		to choose()
			choose from list handlerArray ¬
				with title fp's last text item ¬
				with prompt ("Select a handler:") ¬
				OK button name action ¬
				cancel button name ("Close") ¬
				multiple selections allowed true ¬
				without empty selection allowed
		end choose
		
		to paste()
			if action ≠ "Paste" then return
			
			tell editor's front document's selection ¬
				to set the contents to ¬
				the clipboard as «class ut16»
		end paste
	end script
	
	
	tell the handlerList to ¬
		if H = missing value then
			return its handlerArray as text
		else if H = null then
			set H to choose()
			if H = false then return -- User cancelled
		end if
	
	(handlersByName from fp given name:H) as text
	set the clipboard to the result as «class ut16»
	handlerList's paste()
end run
--------------------------------------------------------------------------------
###HANDLERS
#
#
to resolveAliasPath at fp
	local fp
	
	tell application "System Events" to set fp to file fp as alias
	tell application "Finder" to repeat until fp's kind ≠ "Alias"
		set fp to fp's original item as alias
	end repeat
	
	fp's POSIX path
end resolveAliasPath

to handlersByName from input given name:handlerNames as list : {}
	local input, handlerNames
	
	script scriptfile
		property fp : resolveAliasPath at input
		property f : NSString's stringWithContentsOfFile:fp ¬
			encoding:NSUTF16LE |error|:(missing value)
		property H : NSMutableArray's array()
		
		to listOfHandlers()
			(matchString against ["^\\s*(on|to) ", ¬
				"(?!run\\b|error\\b|set\\b)(\\w+)"] ¬
				thru f onto "$2")'s ¬
				sortedArrayUsingSelector:"compare:"
			
			result as list
		end listOfHandlers
		
		to contentsOfHandlers()
			if handlerNames = {} then return H as list
			set [h0, handlerNames] to [item 1, rest] of handlerNames
			
			H's addObject:(matchString against [¬
				"(on|to) ", h0, ¬
				"\\b.+?end ", h0, ¬
				"\\b.*?$"] thru f onto "$0")
			
			contentsOfHandlers()
		end contentsOfHandlers
	end script
	
	if handlerNames = {} then return scriptfile's listOfHandlers()
	scriptfile's contentsOfHandlers()
end handlersByName

on matchString against pattern thru str onto captureTemplate ¬
	given matchingCase:i as boolean : false ¬
	, anchorsMatchingLines:g as boolean : true ¬
	, dotMatchingLineSeparators:m as boolean : true
	local pattern, str, captureTemplate
	local i, g, m
	
	set [i, g, m] to [i as integer, g as integer, m as integer]
	set pattern to pattern's contents as text
	set str to str's contents as text
	
	set options to ¬
		i * NSRegularExpressionCaseInsensitive + ¬
		g * NSRegularExpressionAnchorsMatchLines + ¬
		m * NSRegularExpressionDotMatchesLineSeparators
	
	set regex to NSRegularExpression's ¬
		regularExpressionWithPattern:pattern ¬
			options:options ¬
			|error|:(missing value)
	
	set matches to regex's matchesInString:str ¬
		options:0 range:{0, str's length}
	
	set results to NSMutableArray's array()
	
	repeat with match in matches
		(results's addObject:(regex's ¬
			replacementStringForResult:match ¬
				inString:str ¬
				|offset|:0 ¬
				template:captureTemplate))
	end repeat
	
	return the results
end matchString
---------------------------------------------------------------------------❮END❯