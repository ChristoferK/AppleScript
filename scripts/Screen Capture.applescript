#!/usr/bin/osascript
--------------------------------------------------------------------------------
# pnam: SCREEN CAPTURE
# nmxt: .applescript
# pDSC: Starts a screen capture in window selection mode, saving the image in
#       to the default screenshots folder with a timestamped filename

# plst: +options : «text»* The file extension to use for the image 
#                : «bool»* Whether or not to reveal the file in Finder

# rslt: «true» : Successful capture
#       «ctxt» : Error message
--------------------------------------------------------------------------------
# sown: CK
# ascd: 2018-02-24
# asmo: 2019-04-16
--------------------------------------------------------------------------------
property sys : application "System Events"
property text item delimiters : space

property types : ["jpg", "png", "tiff", "pdf"]
property cmd : "defaults read com.apple.screencapture location"
property ScreenshotsFolder : do shell script cmd

global type
--------------------------------------------------------------------------------
on run options
	if class of options = script then set options to ["jpg", true]
	set [type, reveal] to options
	
	-- Generate posix path at which to save the screenshot
	make new [{"Screen Shot", timestamp()}, ".", type] at ScreenshotsFolder
	set screenshot to the result as POSIX file
	
	try
		contents of {"SCREENCAPTURE", "-ixWoa", "-t", type, ¬
			quoted form of the screenshot's POSIX path} as text
		do shell script result
	on error E
		return E
	end try
	
	if reveal then tell application "Finder"
		reveal the screenshot
		activate
	end tell
	
	true
end run
--------------------------------------------------------------------------------
# HANDLERS & SCRIPT OBJECTS:
# make
#   Construct a posix filepath that points to a location inside the +directory
#   at which no file exists with the specified +filename, appending (if 
#   necessary) a sequential index.
to make new filename as text at directory as text
	local filename, directory
	
	script
		property index : null
		property ext : "." & type
		property x : type's length
		property basename : filename's text 1 thru -(x + 2)
		
		on fn(i as integer)
			local i
			
			set my index to [space, "#", i] as text
			if 1 ≥ i then set my index to ""
			
			script
				property name : [basename, my index, ext]
				property path : [directory, "/", name] as text
			end script
			
			tell the result to try
				alias POSIX file (its path)
				fn(i + 1)
			on error
				return its path
			end try
		end fn
	end script
	
	result's fn(0)
end make

# timestamp()
#   Return the current date and time formatted as "yyyy-mm-dd at XXhXXm"
on timestamp()
	tell (current date) as «class isot» as string to set ¬
		[d, t] to its [text 1 thru 10, text 12 thru -1]
	contents of {d, "at", [t's word 1, "h", t's word 2, "m"]} as text
end timestamp
---------------------------------------------------------------------------❮END❯