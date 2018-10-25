#!/usr/bin/osascript
--------------------------------------------------------------------------------
# pnam: GET MOUSE POSITION | IDENTIFY UI ELEMENT
# nmxt: .applescript
# pDSC: Identifies the UI element reference located under the mouse cursor

# plst: -

# rslt: �uiel� : A reference to the UI element
#	- : Element not acessible
--------------------------------------------------------------------------------
# sown: CK
# ascd: 2018-09-02
# asmo: 2018-10-25
--------------------------------------------------------------------------------
property lf2 : linefeed & linefeed
--------------------------------------------------------------------------------
# IMPLEMENTATION:
tell application "System Events" to �
	set R to {UIElement:it �
		, UIProperties:properties �
		, UIAttributes:name of attributes �
		, UIActions:name of actions} of �
		(click at my mouseLocation())

set str to coerceToString(R)
set s to a reference to str

replace(s, "UIProperties:", "{UIProperties:")
replace(s, "of application \"System Events\", ", lf2)
replace(s, "{UIElement:", null)

"use application \"System Events\"" & lf2 & s

set the clipboard to the result
get the clipboard
--------------------------------------------------------------------------------
# HANDLERS:
on replace(str, A, B)
	local str, A, B
	
	set the text item delimiters to {B, A}
	set str's contents to str's text items as text
end replace


to coerceToString(object)
	local object
	
	try
		set s to object as text
	on error E --> "Can�t make %object% into type text."
		set d to the text item delimiters
		set the text item delimiters to "Can�t make "
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
			set [list, [number, height]] to �
				NSScreen's �
				mainScreen()'s �
				frame()
			
			tell NSEvent's mouseLocation() to �
				{its x, height - (its y)}
		end mouseLocation
	end script
	
	result's mouseLocation()
end mouseLocation
--------------------------------------------------------------------------:END #