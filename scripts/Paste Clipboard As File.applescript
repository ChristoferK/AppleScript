#!/usr/bin/osascript
--------------------------------------------------------------------------------
###Paste Clipboard As File.applescript
#
#	Pastes the contents of the clipboard as a new file in Finder.  The
#	compatible data types are image data (JPEG) and plain text, which
#	create a .JPG and .TXT file respectively.
#
#  Input:
#	None
#
#  Result:
#	File Pasted in Finder
--------------------------------------------------------------------------------
#  Author: CK
#  Date Created: 2018-04-17
#  Date Last Edited: 2018-08-17
--------------------------------------------------------------------------------
property text item delimiters : space
--------------------------------------------------------------------------------
###IMPLEMENTATION
#
#
on run
	# Get the clipboard's multiple data objects 
	# in a record containing each of data types,
	# then test for particular types.
	set cbObj to the clipboard as record
	
	try
		set cbData to cbObj's string
		set fmt to "txt"
	on error
		try
			set cbData to cbObj's JPEG picture
			set fmt to "jpg"
		on error
			return beep
		end try
	end try
	
	# The filename which to write the data
	set fname to {"Pasted from Clipboard on", ¬
		ISOd(), "at", [ISOt(), ".", fmt]}
	
	# Create the file.
	# Write the data to it.
	tell application "Finder"
		set f to (make new file at insertion location as alias ¬
			with properties {name:fname as text}) as alias
		
		if cbData's class = JPEG picture then
			write cbData to f
		else
			write cbData as «class utf8» to f
		end if
		
		reveal f -- OR: set selection to f
	end tell
end run
--------------------------------------------------------------------------------
###HANDLERS
#
#
on ISOd()
	do shell script "DATE +'%Y-%m-%d'"
end ISOd

on ISOt()
	do shell script "DATE +'%H.%M'"
end ISOt
---------------------------------------------------------------------------❮END❯