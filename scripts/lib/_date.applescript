#!/usr/bin/osascript
--------------------------------------------------------------------------------
# pnam: _DATE
# nmxt: .applescript
# pDSC: Date and time handlers
--------------------------------------------------------------------------------
# sown: CK
# ascd: 2018-09-06
# asmo: 2018-10-30
--------------------------------------------------------------------------------
property name : "_date"
property id : "chrisk.applescript._date"
property version : 1.0
property _date : me
property parent : AppleScript
--------------------------------------------------------------------------------
# HANDLERS & SCRIPT OBJECTS:
to make given year:y, month:m, day:d ¬
	, hours:h : 0, minutes:mm : 0, seconds:s : 0
	local y, m, d, h, mm, s
	
	tell (the current date) to set ¬
		[ASdate, year, its month, day, time] to ¬
		[it, y, m, d, h * hours + mm * minutes + s]
	ASdate
end make


on ISOdate from ASdate as date
	ASdate as «class isot» as string
	return [text 1 thru 10, text 12 thru 19] of the result
	
	-- Alternative method:
	set [y, m, d, t] to [year, month, day, time string] of ASdate
	return [the contents of [y, ¬
		"-", text -1 thru -2 of ("0" & (m as integer)), ¬
		"-", text -1 thru -2 of ("0" & (d as integer))] ¬
		as text, t]
end ISOdate


on now() -- Unix time (in seconds)
	make given year:1970, month:January, day:1
	((current date) - result) as yards as string
end now


on AppleTimeToASDate(t as number)
	local t
	
	make given year:2001, month:January, day:1
	result + t
end AppleTimeToASDate


on timer()
	global |!now|
	
	script timer
		property duration : 0
		
		on start()
			copy time of (current date) to |!now|
			0
		end start
		
		on finish()
			set duration to (time of (current date)) - |!now|
			set |!now| to null
		end finish
	end script
	
	try
		|!now|
	on error
		return timer's start()
	end try
	
	if the result = null then return timer's start()
	
	tell timer to finish()
	get timer's duration
end timer
---------------------------------------------------------------------------❮END❯