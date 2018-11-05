#!/usr/bin/osascript
--------------------------------------------------------------------------------
# pnam: URL PARSER#KM
# nmxt: .applescript
# pDSC: URL scheme parser for km://

# plst: +|url| : The URL

# rslt: -      : Keyboard Maestro macro triggered
#       -      : Macro revealed in Keyboard Maestro interface
--------------------------------------------------------------------------------
# sown: CK
# ascd: 2018-10-30
# asmo: 2018-11-04
--------------------------------------------------------------------------------
property scheme : "km"
property text item delimiters : {scheme & "://", scheme & ":", "&", "="}
--------------------------------------------------------------------------------
# IMPLEMENTATION:
on run |url|
	if |url|'s class = script then set |url| to ¬
		["km://name=Preview Clipboard&trigger="]
	set [|url|] to |url|
	
	if the |url| does not start with my scheme & ":" then ¬
		set |url| to my scheme & "://" & |url|
	
	set macro to parse(|url|)
	
	if the macro's trigger ≠ null then
		set [m] to text of [macro's name, macro's id]
		tell application "Keyboard Maestro Engine" to return ¬
			do script m with parameter macro's trigger
	end if
	
	tell application "Keyboard Maestro"
		set m to a reference to (the first macro whose ¬
			name = the |macro|'s name as text ¬
			or id = the |macro|'s id as text)
		
		if not (m exists) then error "No macro by that name exists."
		
		run
		select m
		activate
	end tell
end run
--------------------------------------------------------------------------------
# HANDLERS & SCRIPT OBJECTS:
to parse(|url|)
	local |url|
	
	script params
		property list : text items of |url|
		
		script macro
			property id : null
			property name : null
			property trigger : null
		end script
	end script
	
	tell params
		if (length of its list) = 2 then
			set its macro's name to item 2 of its list
		else if (length of its list) > 2 then
			repeat with i from 2 to its list's length by 2
				set [p, v] to the contents of its list's ¬
					[item i, item (i + 1)]
				
				if p = "name" then
					set its macro's name to v
				else if p = "trigger" then
					set its macro's trigger to v
				else if p = "id" then
					set its macro's id to v
				end if
			end repeat
		end if
		
		its macro
	end tell
end parse
---------------------------------------------------------------------------❮END❯