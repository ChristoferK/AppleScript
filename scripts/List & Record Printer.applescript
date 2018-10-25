#!/usr/bin/osascript
--------------------------------------------------------------------------------
# pnam: RECORD & LIST PRINTER
# nmxt: .applescript
# pDSC: Pretty prints a text representation of an AppleScript list or record

# plst: ％input％ : A list or record or a string representation of such

# rslt: «ctxt» : Pretty-printed string representation of the input
--------------------------------------------------------------------------------
# sown: CK
# ascd: 2018-10-20
# asmo: 2018-10-25
--------------------------------------------------------------------------------
use framework "Foundation"
use scripting additions

property this : a reference to current application

property NSString : a reference to NSString of this
property NSScanner : a reference to NSScanner of this
property NSCharacterSet : a reference to NSCharacterSet of this
--------------------------------------------------------------------------------
# IMPLEMENTATION:
on run input
	if input's class = script then set input to ["{{a:5, b:\"Hello\", " & ¬
		"c:{x:1, y:2, z:{alpha:1}, u:8}, d:{{3, 4, {6, 7}, 5}, " & ¬
		"{\"a\", 5}}, f:0}}"]
	set [input] to the input
	set input to its |string|:input
	
	scanString(input)
	(mapItems of output thru tabulate) as text
end run
--------------------------------------------------------------------------------
# HANDLERS & SCRIPT OBJECTS:
to |string|:input
	local input
	
	if the input's class ≠ list then
		try
			set s to input as text
		on error E --> "Can’t make %object% into type text."
			set my text item delimiters to "Can’t make "
			set s to rest of the text items of E as text
			
			set my text item delimiters to " into type text."
			set s to text items 1 thru -2 of s as text
		end try
	else
		repeat with x in the input
			set x's contents to (its |string|:(x's contents))
		end repeat
		
		set my text item delimiters to ", "
		set s to ["[", the input, "]"] as text
	end if
	
	s
end |string|:


to scanString(input)
	set withinQuotes to false
	
	set chars to "[{}],\""
	set quoteSet to NSCharacterSet's characterSetWithCharactersInString:"\""
	set charSet to NSCharacterSet's characterSetWithCharactersInString:chars
	
	tell (NSScanner's scannerWithString:input) to repeat until ¬
		(its atEnd as boolean)
		
		scanUpToCharactersFromSet_intoString_(charSet, reference)
		set [bool, s] to the result
		if bool = true then addToEnd(s as text) of my output
		
		scanCharactersFromSet_intoString_(charSet, reference)
		set [bool, t] to the result
		if bool = true then addToEnd((t as text)'s characters) ¬
			of my output
		
	end repeat
	
	my output's refactor()
end scanString


script output
	property result : {}
	
	to addToEnd(x as list)
		local x
		
		set my result to my result & x
	end addToEnd
	
	to refactor()
		tell my result to repeat with i from 2 to (its length) - 1
			set x to (a reference to its item i)
			set y to (a reference to its item (i - 1))
			set z to (a reference to its item (i + 1))
			
			if x ends with ":" then
				set its item (i + 1) to x & z
				set its item i to null
			end if
			
			if (x contains quote and ¬
				(x does not end with quote or ¬
					x ends with ":\"" or ¬
					x's contents = quote)) or ¬
				x ends with quote and ¬
				z's contents is not in [",", "}", "]"] then
				
				set its item (i + 1) to x & z
				set its item i to null
			end if
		end repeat
		
		set my result to strings in my result
	end refactor
	
	to mapItems thru function at i : {}
		local function, level
		
		script |items|
			property list : my result
		end script
		
		tell |items| to repeat with x in ¬
			(a reference to its list)
			
			tell wrapper(function) to set ¬
				[i, contents of x] to ¬
				fn(i, contents of x)
		end repeat
		
		my result
	end mapItems
	
	on wrapper(function)
		if function's class = script then ¬
			return function
		
		script
			property fn : function
		end script
	end wrapper
end script


on tabulate(N, x)
	local N, x
	
	set text item delimiters to ""
	
	if x is in "[{" then return [N & tab, [N, x, return] as text]
	if x = "," then return [N, [x, return] as text]
	if x is in "]}" then return [rest of N, ¬
		contents of [return, rest of N, x] as text]
	--else:
	set a to offset of ":" in x
	if a > 0 then set x to the contents of [¬
		text 1 thru a of x, space, ¬
		text (a + 1) thru -1 of x] as text
	if x ends with "{" then return [N & tab, [N, x, return] as text]
	return [N, [N, x] as text]
end tabulate
--------------------------------------------------------------------------:END #