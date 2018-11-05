#!/usr/bin/osascript
--------------------------------------------------------------------------------
# pnam: URL PARSER#APPLESCRIPT
# nmxt: .applescript
# pDSC: URL scheme parser for applescript://

# plst: +|url| : The URL

# rslt: -      : AppleScript file opened
--------------------------------------------------------------------------------
# sown: CK
# ascd: 2018-10-30
# asmo: 2018-11-04
--------------------------------------------------------------------------------
property parent : script "load.scpt"
property scheme : "applescript"
property path : rootdir
property text item delimiters : {scheme & "://", scheme & ":", "&", "="}
--------------------------------------------------------------------------------
# IMPLEMENTATION:
on run |url|
	if |url|'s class = script then set |url| to ¬
		["applescript://URL Parser#applescript.applescript"]
	set [|url|] to |url|

	if the |url| does not start with my scheme & ":" then ¬
		set |url| to my scheme & "://" & |url|
	
	set fp to my path & "/" & |url|'s text item 2
	set f to Finder's file (sys's file fp as alias)
	tell (f's «class orig») to if exists then set f to it
	tell application "Script Editor" to open (f as alias)
end run
---------------------------------------------------------------------------❮END❯