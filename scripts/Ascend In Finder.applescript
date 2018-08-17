#!/usr/bin/osascript
--------------------------------------------------------------------------------
###Ascend In Finder.applescript
#
#	Takes a selection of files in Finder and moves them up one level in
#	the directory tree.  Files within the home sub-tree will not be moved
#	higher than the home directory.
#
#  Input:
#	-				Type
#
#  Result:
#	 0				Files are in the home directory
#	-1				Finder not frontmost; OR focussed window
#					is not a Finder window
#	⟨file references⟩		The ascended files
--------------------------------------------------------------------------------
#  Author: CK
#  Date Created: 2018-03-03
#  Date Last Edited: 2018-08-17
--------------------------------------------------------------------------------
use Finder : application "Finder"
use scripting additions
--------------------------------------------------------------------------------
property home : Finder's home as alias
property dfol : path to desktop folder
--------------------------------------------------------------------------------
###IMPLEMENTATION
#
#
on run
	-- Check Finder is frontmost
	name of the application named (path to frontmost application)
	if the result is not in ["Finder", "Script Editor"] then return -1
	
	set _F to the insertion location as alias -- Selection's folder
	set __F to _F & "::" as text as alias -- Its (grand)parent folder
	
	-- Verify appropriate window focus
	if _F ≠ dfol then if ¬
		the front Finder window is not ¬
		Finder's front window then ¬
		return -1
	
	-- Don't ascend higher than ~/ or /
	if _F's POSIX path is in [home's POSIX path, "/"] then
		beep
		return 0
	end if
	
	
	set S to Finder's selection as alias list
	-- Exclude files that would overwrite a pre-existing file
	tell Finder to repeat with f in S
		try
			contents of [__F as text, name of f] as text as alias
			set contents of f to missing value
		end try
	end repeat
	set S to the aliases of S
	
	
	tell Finder to reveal (move S to __F)
	activate Finder
end run
---------------------------------------------------------------------------❮END❯