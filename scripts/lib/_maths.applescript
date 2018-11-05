#!/usr/bin/osascript
--------------------------------------------------------------------------------
# pnam: _MATHS
# nmxt: .applescript
# pDSC: Mathematical functions.  Loading this library also loads _arrays lib.
--------------------------------------------------------------------------------
# sown: CK
# ascd: 2018-11-04
# asmo: 2018-11-04
--------------------------------------------------------------------------------
property name : "_maths"
property id : "chri.sk.applescript._maths"
property version : 1.0
property _maths : me
property libload : script "load.scpt"
property parent : libload's load("_arrays")
--------------------------------------------------------------------------------
# HANDLERS & SCRIPT OBJECTS:
script Node
	script Node
		property data : missing value
		property |left| : null
		property |right| : null
	end script
	
	to make with data d
		set N to Node
		set N's data to d
		return N
	end make
end script


on GCD:L
	local L
	
	script
		property array : L
		
		on GCD(x, y)
			local x, y
			
			repeat
				if x = 0 then return y
				set [x, y] to [y mod x, x]
			end repeat
		end GCD
	end script
	
	tell the result to foldItems from its array ¬
		at item 1 of its array ¬
		given handler:its GCD
end GCD:


on LCM:L
	local L
	
	script
		property array : L
		
		on GCD(x, y)
			local x, y
			
			repeat
				if x = 0 then return y
				set [x, y] to [y mod x, x]
			end repeat
		end GCD
		
		on LCM(x, y)
			local x, y
			
			set xy to x * y
			repeat
				if x = 0 then exit repeat
				set [x, y] to [y mod x, x]
			end repeat
			
			xy / y as integer
		end LCM
	end script
	
	tell the result to foldItems from its array ¬
		at item 1 of its array ¬
		given handler:its LCM
end LCM:


to floor(x)
	local x
	
	x - 0.5 + 1.0E-15 as integer
end floor


on ceil(x)
	local x
	
	floor(x) + 1
end ceil


to sqrt(x)
	local x
	
	x ^ 0.5
end sqrt


on Roman(N as integer)
	local N
	
	script numerals
		property list : words of "I IV V IX X XL L XC C CD D CM M"
		property value : "1 4 5 9 10 40 50 90 100 400 500 900 1000"
		property string : {}
	end script
	
	
	repeat with i from length of list of numerals to 1 by -1
		set glyph to item i in the list of numerals
		set x to item i in the words of numerals's value
		
		make (N div x) at glyph
		set string of numerals to string of numerals & result
		set N to N mod x
	end repeat
	
	return the string of numerals as linked list as text
end Roman


on primes(N as integer)
	local N
	
	script primes
		property list : make N
	end script
	
	repeat with p from 2 to sqrt(N)
		if item p in the list of primes ≠ false then ¬
			repeat with i from 2 * p to N by p
				set item i in the list of primes to false
			end repeat
	end repeat
	
	return the rest of the numbers in the list of primes
end primes


to factorise(N as integer)
	local N
	
	script factors
		property list : {}
	end script
	
	repeat while N mod 2 = 0
		set end of list of factors to 2
		set N to N / 2
	end repeat
	
	repeat with i from 3 to sqrt(N) by 2
		repeat while N mod i = 0
			set end of list of factors to i
			set N to N / i
		end repeat
	end repeat
	
	if N > 2 then set end of list of factors to N as integer
	
	return the list of factors
end factorise
---------------------------------------------------------------------------❮END❯