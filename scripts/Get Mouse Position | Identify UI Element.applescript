#!/usr/bin/osascript
--------------------------------------------------------------------------------
###Get Mouse Position | Identify UI Element.applescript
#
#	Description
#
#  Input:
#	％argument％			Type
#
#  Result:
#	％value％			Explanation
--------------------------------------------------------------------------------
#  Author: CK
#  Date Created: 2018-09-02
#  Date Last Edited: 2018-09-05
--------------------------------------------------------------------------------
###IMPLEMENTATION
#
#
tell application "System Events" to ¬
	set R to {UIElement:it ¬
		, UIProperties:properties ¬
		, UIAttributes:name of attributes ¬
		, UIActions:name of actions} of (click at my mouseLocation())

set s to coerceToString(R)

replace of (a reference to s) from "UIProperties:" to "{UIProperties:"
replace of (a reference to s) ¬
	from ("of application \"System Events\", ") ¬
	to linefeed & linefeed
replace of (a reference to s) from "{UIElement:" to null

"use application \"System Events\"" & linefeed & linefeed & s

set the clipboard to the result
get the clipboard
--------------------------------------------------------------------------------
###HANDLERS
#
#
to replace of str from A to B
	local str, A, B
	
	set the text item delimiters to {B, A}
	set str's contents to str's text items as text
end replace

to coerceToString(object)
	local object
	
	try
		set s to object as text
	on error E --> "Can’t make %object% into type text."
		set d to the text item delimiters
		set the text item delimiters to "Can’t make "
		set s to text items 2 thru -1 of E as text
		
		set the text item delimiters to " into type text."
		set s to text items 1 thru -2 of s as text
		
		set the text item delimiters to d
	end try
	
	return s
end coerceToString

on mouseLocation()
	script
		use framework "Foundation"
		
		property this : a reference to current application
		property parent : this
		property NSEvent : a reference to NSEvent of this
		property NSScreen : a reference to NSScreen of this
		
		on mouseLocation()
			set [list, [number, height]] to ¬
				NSScreen's ¬
				mainScreen()'s ¬
				frame()
			
			tell NSEvent's mouseLocation() to ¬
				{its x, height - (its y)}
		end mouseLocation
	end script
	
	result's mouseLocation()
end mouseLocation
---------------------------------------------------------------------------❮END❯