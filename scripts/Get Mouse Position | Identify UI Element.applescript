#!/usr/bin/osascript
--------------------------------------------------------------------------------
# pnam: GET MOUSE POSITION | IDENTIFY UI ELEMENT
# nmxt: .applescript
# pDSC: Identifies the UI element reference located under the mouse cursor

# plst: -

# rslt: «text» : A script containing a reference to the UI element's properties
#       -      : Element not accessible
--------------------------------------------------------------------------------
# sown: CK
# ascd: 2018-09-02
# asmo: 2019-06-09
--------------------------------------------------------------------------------
use application "System Events"
use scripting additions
--------------------------------------------------------------------------------
# IMPLEMENTATION:
set s to __string__({UIElement:it ¬
	, UIProperties:properties ¬
	, UIAttributes:name of attributes ¬
	, UIActions:name of actions} of ¬
	(click at my mouseLocation()))

-- Text manipulation -- 
set [a, b, c] to [length of "{UIElement:", ¬
	offset of "of application \"System Events\", " in s, ¬
	length of "of application \"System Events\", "]
set UIElement to text (1 + a) thru (b - 2) of s
set UIRecord to ["{", text (b + c) thru -1 of s]

-- Composite string --
set UIString to the contents of [¬
	"use application \"System Events\"", ¬
	linefeed, linefeed, UIElement, ¬
	linefeed, linefeed, UIRecord] as text


set the clipboard to the UIString
return the UIString
--------------------------------------------------------------------------------
# HANDLERS:
# __string__()
#   Returns a string representation of an AppleScript object
to __string__(object)
	local object
	
	if the object's class = text then return the object
	
	try
		set s to object as missing value
	on error E --> "Can’t make %object% into type missing value."
		set tid to the text item delimiters
		set the text item delimiters to "Can’t make "
		set s to text items 2 thru -1 of E as text
		
		set the text item delimiters to " into type missing value."
		set s to text items 1 thru -2 of s as text
		
		set the text item delimiters to tid
	end try
	
	return s
end __string__

# mouseLocation()
#   Gets the current cursor position relative to the top-left corner of the
#   screen
on mouseLocation()
	script
		use framework "Foundation"
		use framework "AppKit"
		
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