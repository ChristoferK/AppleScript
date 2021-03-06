#!/usr/bin/osascript
--------------------------------------------------------------------------------
# pnam: SCREEN CAPTURE
# nmxt: .applescript
# pDSC: Starts a screen capture in window selection mode, saving the image in
#       to the default screenshots folder with a timestamped filename

# plst: +options : «text»* The file extension to use for the image 
#                : «bool»* Whether or not to reveal the file in Finder

# rslt: «bool»     : Indicates success or failure of screencapturing
#       «sysnotif» : Error message
--------------------------------------------------------------------------------
# sown: CK
# ascd: 2018-02-24
# asmo: 2019-05-20
--------------------------------------------------------------------------------
use scripting additions
property sys : application "System Events"
property text item delimiters : space

property types : ["jpg", "png", "tiff", "pdf"]
property cmd : "defaults read com.apple.screencapture location"
property Screenshots : do shell script cmd

# Defaults:
property file type : "jpg"
property reveal : true
property defaults : {file type, reveal}
--------------------------------------------------------------------------------
on run options
	set options to {options, defaults}
	set {options} to lists of options
	set {file type, reveal} to options
	
	-- Generate path at which to save the screenshot
	set filename to [{"Screen Shot", current date}, ".", file type]
	choose file name default name filename default location Screenshots
	set Screenshot to the result
	
	try
		contents of {"SCREENCAPTURE", "-ixWoa", "-t", file type, ¬
			quoted form of the Screenshot's POSIX path} as text
		do shell script result
	on error E
		display notification E
		return false
	end try
	
	if reveal then tell application "Finder"
		reveal the Screenshot
		activate
	end tell
	
	true
end run
--------------------------------------------------------------------------------
# HANDLERS & SCRIPT OBJECTS:
# choose file name
#   Construct a filepath that points to a location inside the +directory, 
#   appending (if necessary) an incrementing index until a path is obtained
#   at which no item exists.  Returns an HFS path.
to choose file name default name filename as text default location directory
	local filename, directory
	global file type
	
	script
		using terms from application "System Events"
			property id : missing value
			property kind : "." & file type
			property index : (file type's length) + 2
			property name : filename's text 1 thru -index
			property dir : path of sys's item named directory
			
			on fn(i as integer)
				local i
				
				set my id to [space, "#", i] as text
				if 1 ≥ i then set my id to ""
				
				script fileitem
					property name : [my name, my id, kind]
					property path : [dir, name] as text
				end script
				
				try
					fileitem's path as alias
					return fn(i + 1)
				on error
					fileitem's path
				end try
			end fn
		end using terms from
	end script
	
	result's fn(0)
end choose file name

# current date
#   Returns the current date and time formatted as "yyyy-mm-dd at HHhMMm"
on current date
	tell (continue current date) as «class isot» as string to ¬
		set [d, t] to its [text 1 thru 10, text 12 thru -1]
	contents of {d, "at", [t's word 1, "h", t's word 2, "m"]} as text
end current date
---------------------------------------------------------------------------❮END❯