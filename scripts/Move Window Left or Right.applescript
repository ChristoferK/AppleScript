#!/usr/bin/osascript
--------------------------------------------------------------------------------
###Move Window Left or Right.applescript
#
#	Shifts the currently focussed window left- or rightwards to align
#	itself with the contralateral edge of closest window in its path,
#	or to the edge of the screen if no windows remain. 
#
#  Input:
#	％t％				An integer whose sign determines the
#					direction of travel
#
#  Return Values:
#	None				Window moves
--------------------------------------------------------------------------------
#  Author: CK
#  Date Created: 2018-02-26
#  Date Last Edited: 2018-08-08
--------------------------------------------------------------------------------
on run t
	if (count t) = 0 then set t to [-1]
	set [t] to t
	
	moveWindow(t)
end run
--------------------------------------------------------------------------------
###HANDLERS
#
#
to moveWindow(t as integer)
	script win
		use application "System Events"
		
		property _P : a reference to every process
		property _Q : a reference to ¬
			(_P whose class of windows contains window)
		property _W : a reference to every window of _Q
		property P : item 1 of (_P whose frontmost is true)
		property W : front window of P
		-- Desktop:
		property D : size of scroll area 1 of process "Finder"
		
		property moveLeft : t < 0
		
		property xs : everyNthItem(flatten(position of _W), 1, 2)
		property ws : everyNthItem(flatten(size of _W), 1, 2)
		property |x+w| : sort(unique(add(xs, ws)))
		
		property xy : W's position
		property WxH : W's size
	end script
	
	tell win
		set screenX to item 1 of its D
		set [|left|, top] to [item 1, item 2] of its xy
		set [width, height] to [item 1, item 2] of its WxH
		
		if |left| ≤ 0 and its moveLeft = true then return
		if its moveLeft = false and ¬
			(|left| + width + 1) ≥ screenX then ¬
			return
		
		if its moveLeft then
			repeat with x in the reverse of its |x+w|
				if (x + 1) < |left| then
					set «class posn» of its W to ¬
						[x + 1, top]
					return
				end if
			end repeat
			
			set «class posn» of its W to [0, top]
		else
			repeat with x in sort(unique(its xs))
				if (x - 1) > (|left| + width) then
					set «class posn» of its W to ¬
						[x - width - 1, top]
					return
				end if
			end repeat
			
			set «class posn» of its W to [screenX - width, top]
		end if
	end tell
end moveWindow
--------------------------------------------------------------------------------
###LIST MANIPULATION HANDLERS
#
#
to flatten(L)
	local L
	
	if L = {} then return {}
	if L's class ≠ list then return {L}
	
	script
		property Array : L
	end script
	
	tell the result
		set [x0, xN] to [first item, rest] of its Array
		flatten(x0) & flatten(xN)
	end tell
end flatten

on everyNthItem(L as list, i as integer, n as integer)
	local L, i, n
	
	if (i > L's length) then return {}
	
	script
		property Array : L
		property |*L| : {}
	end script
	
	tell the result
		repeat with j from i to L's length by n
			set end of its |*L| to item j of its Array
		end repeat
		
		its |*L|
	end tell
end everyNthItem

on unique(L as list)
	local L
	
	if L = {} then return {}
	
	script
		property Array : L
		property fn : unique
	end script
	
	tell the result
		set [x0, xN] to [first item, rest] of its Array
		if x0 is in xN then return its fn(xN)
		[x0] & its fn(xN)
	end tell
end unique

to add(A as list, B as list)
	if A = {} and B = {} then return {}
	if A = {} then set A to {0}
	if B = {} then set B to {0}
	
	script
		property Array1 : A
		property Array2 : B
	end script
	
	tell the result
		set x to (item 1 of its Array1) + ¬
			(item 1 of its Array2)
		{x} & add(rest of its Array1, rest of its Array2)
	end tell
end add

to sort(L as list)
	local L
	
	if L = {} then return {}
	if L's length = 1 then return L
	
	script
		on minimum(L as list)
			local L
			
			if L is {} then return {}
			if L's length = 1 then ¬
				return L's first item
			
			script
				property Array : L
			end script
			
			tell the result
				set [x0, xN] to [first item, rest] of its Array
				set min to minimum(xN)
				if x0 < min then return x0
				min
			end tell
		end minimum
		
		on lastIndexOf(x, L as list)
			local x, L
			
			if x is not in L then return 0
			if L = {} then return 0
			
			script
				property Array : L
			end script
			
			tell the result
				set [x0, xN] to [¬
					last item, ¬
					reverse of ¬
					rest of ¬
					reverse] of its Array
			end tell
			
			if x = x0 then return 1 + (xN's length)
			lastIndexOf(x, xN)
		end lastIndexOf
		
		to swap(L as list, i as integer, j as integer)
			local i, j, L
			
			set x to item i of L
			set item i of L to item j of L
			set item j of L to x
		end swap
		
		property Array : L
	end script
	
	tell the result
		set i to its lastIndexOf(its minimum(its Array), its Array)
		if i ≠ 1 then swap(its Array, 1, i)
		return [item 1 of its Array] & sort(rest of its Array)
	end tell
end sort
---------------------------------------------------------------------------❮END❯