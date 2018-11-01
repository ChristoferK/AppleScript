#!/usr/bin/osascript
--------------------------------------------------------------------------------
# pnam: _TEXT
# nmxt: .applescript
# pDSC: String manipulation handlers
--------------------------------------------------------------------------------
# sown: CK
# ascd: 2018-08-31
# asmo: 2018-10-31
--------------------------------------------------------------------------------
property name : "_text"
property id : "chrisk.applescript._text"
property version : 1.0
property _text : me
#property parent : script "load.scpt"
#property _array : load script "_array"
--------------------------------------------------------------------------------
property tid : AppleScript's text item delimiters
--------------------------------------------------------------------------------
# HANDLERS & SCRIPT OBJECTS:
on tid:(d as list)
	local d
	
	if d = {} or d = {0} then
		set d to tid
	else if d's item 1 = null then
		set n to random number from 0.0 to 1.0
		set d's first item to (1 / pi) * n
	end if
	
	set tid to AppleScript's text item delimiters
	set AppleScript's text item delimiters to d
end tid:


to glue(a as list, x)
	script
		property list : a
		property chars : items in x
	end script
	
	tell result to repeat with i from 2 to length of its list
		set [s, t] to its list's [item (i - 1), item i]
		
		set y to its chars's item 1's contents
		set its chars to its chars & y
		set its chars to rest of its chars
		
		set its list's item i to my concat(s, t, y)
		set its list's item (i - 1) to null
	end repeat
	
	a's last item
end glue


on concat(a as text, b as text, x as text)
	[a, x, b] as text
end concat

glue(["a", "b", "c", "d", "e"], "*.")
---------------------------------------------------------------------------❮END❯