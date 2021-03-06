#!/usr/bin/osascript
--------------------------------------------------------------------------------
###Finder Scroll To Top.applescript
#
#	Scrolls a Finder window to the top-left of the window in icon-, list-, 
#	and flow-views only.  If the window was already at the top, Finder will
#	ascend to the parent directory.
#
#  Input:
#	None			Acts upon the active Finder window
#
#  Return Values:
#	-1			Nothing to do because:
#					- No Finder window exists;
#					- Current view is Column View; OR:
#					- Already at the root directory
#	 0			Finder window doesn't have focus
#	 1			Successful scroll to top
#	 2			Ascended to parent directory
--------------------------------------------------------------------------------
#  Author: CK
#  Date Created: 2018-02-24
#  Date Last Edited: 2018-08-09
--------------------------------------------------------------------------------
###IMPLEMENTATION
#
#
-- Column view follows a different GUI object heirarchy 
-- ∴ terminate script if in column view
tell application "Finder" to tell the front Finder window to ¬
	if not (exists) or its current view is not in ¬
		[icon view, list view, flow view] then ¬
		return -1 --> No Finder window exists or it is in Column View


tell application "System Events" to tell the ¬
	application process "Finder" to tell ¬
	the front window
	
	if its description ≠ "standard window" then ¬
		return 0 --> Non-standard window, e.g. preferences, info
	
	
	tell splitter group 1 to if exists then set S to it
	tell (splitter group 1 of S) to if exists then set S to it
	-- Flow view has a third splitter group
	tell (splitter group 1 of S) to if exists then set S to it
	tell (scroll areas in S) to if exists then set S to it
	
	-- Used to determine if scroll bars are already at top (zeroed)
	set z to true
	
	-- Each scroll area in splitter group 1
	repeat with A in S
		tell (scroll bars in A) to if exists then
			its value is in [0, 0, 0, 0]
			set z to z and the result
			set its value to 0.0
		end if
	end repeat
end tell

if z = false then return 1 --> Successful scroll to top


-- If z is true, the scrollbars were already at 0.
-- Therefore, go up one directory level instead, and
-- highlight the folder we just came from.
tell application "Finder" to tell the front Finder window to ¬
	try
		set child to its target
		set target to the parent of its target
		select the child
	on error
		-- Probably can't go up any higher
		beep
		return 0 -- Already at the root directory
	end try

2 --> Ascended to parent directory
---------------------------------------------------------------------------❮END❯