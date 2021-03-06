#!/usr/bin/osascript
--------------------------------------------------------------------------------
# pnam: URL PARSER#KM
# nmxt: .applescript
# pDSC: URL scheme parser for km://

# plst: +URLpath : The URL without the scheme component

# rslt: - Keyboard Maestro macro triggered
#       - Macro revealed in Keyboard Maestro interface
--------------------------------------------------------------------------------
# sown: CK
# ascd: 2018-10-30
# asmo: 2019-05-01
--------------------------------------------------------------------------------
use KM : application "Keyboard Maestro"
use application "Keyboard Maestro Engine"

property scheme : "km"
property text item delimiters : "?value="
--------------------------------------------------------------------------------
# IMPLEMENTATION:
on run URLpath
	if URLpath's class = script then set the URLpath ¬
		to ["Preview Clipboard?value="]
	set [URLpath] to the URLpath
	set URLPathItems to URLpath's text items
	
	set M to {name:item 1 of URLPathItems, value:missing value}
	if the number of URLPathItems = 2 then set the ¬
		M's value to item 2 of URLPathItems
	
	set _M to a reference to (the first macro whose ¬
		name contains the M's name or id = M's name)
	if not (_M exists) then error "No macro by that name exists."
	
	set M's name to _M's name as text
	if M's value ≠ missing value then return do script ¬
		M's name with parameter M's value
	
	select _M
	activate KM
end run
---------------------------------------------------------------------------❮END❯