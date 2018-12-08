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
# asmo: 2018-12-08
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
	
	-- Create Posix Path for new screenshot and ensure uniqueness
	set fp to [ScreenshotsFolder, "/", {"Screen Shot", timestamp()}, ¬
		".", type] as text
	
	set Screenshot to make at fp
	
	try
		contents of {"SCREENCAPTURE", "-ixWoa", "-t", type, ¬
			Screenshot's quoted form} as text
		do shell script result
	on error E
		return E
	end try
	
	if reveal then tell application "Finder"
		reveal Screenshot as POSIX file
		activate
	end tell
	
	true
end run
--------------------------------------------------------------------------------
# HANDLERS & SCRIPT OBJECTS:
to make at fp
	local fp
	
	script
		property index : null
		property folder : dir(fp)
		property base : basename(fp)
		property extn : "." & type
		
		on fn(i as integer)
			local i
			
			set my index to [space, "#", i]
			if 1 ≥ i then set my index to ""
			
			script
				property name : [base, my index as text, extn]
				property path : [my folder as text, "/", name]
			end script
			
			tell the result
				try
					alias POSIX file (its path as text)
					fn(i + 1)
				on error
					return its path as text
				end try
			end tell
		end fn
	end script
	
	result's fn(0)
end make


on dir(fp as text)
	(POSIX file fp as text) & "::"
	«class posx» of sys's item result
end dir


on filename(fp as text)
	set x to dir(fp)'s length
	fp's text (x + 2) thru -1
end filename


on basename(fp as text)
	set x to (type's length)
	filename(fp)'s text 1 thru -(x + 2)
end basename


on timestamp()
	tell (current date) as «class isot» as string to set ¬
		[d, t] to its [text 1 thru 10, text 12 thru -1]
	contents of {d, "at", [t's word 1, ".", t's word 2]} as text
end timestamp
---------------------------------------------------------------------------❮END❯