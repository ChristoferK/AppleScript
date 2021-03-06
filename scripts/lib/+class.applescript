#!/usr/bin/osascript
--------------------------------------------------------------------------------
# pnam: +CLASS
# nmxt: .applescript
# pDSC: Class manipulation and introspection handlers
--------------------------------------------------------------------------------
# sown: CK
# ascd: 2018-12-10
# asmo: 2019-06-09
--------------------------------------------------------------------------------
property name : "class"
property id : "chri.sk.applescript.lib:class"
property version : 1.0
property parent : AppleScript
--------------------------------------------------------------------------------
use framework "Foundation"
use scripting additions

property this : a reference to current application
property nil : a reference to missing value
property _1 : a reference to reference

property NSAEDescriptor : a reference to NSAppleEventDescriptor of this
property NSArray : a reference to NSArray of this
property NSCoercion : a reference to NSScriptCoercionHandler of this
property NSDictionary : a reference to NSDictionary of this
property NSExpression : a reference to NSExpression of this
property NSNumber : a reference to NSNumber of this
property NSObject : a reference to NSObject of this
property NSSet : a reference to NSSet of this
property NSString : a reference to NSString of this
property NSURL : a reference to NSURL of this

property SEL : {NSObject:"new", NSArray:"arrayWithArray:", NSString:¬
	"stringWithString:", NSDictionary:"dictionaryWithDictionary:", NSURL:¬
	"fileURLWithPath:", NSSet:"setWithArray:", NSExpression:¬
	"expressionForConstantValue:"}

property PRO : {list:{}, text:"", number:1, record:{{null:missing value}} ¬
	, string:"", integer:0, real:0.0, boolean:true, URL:"", alias:alias ¬
	, POSIX file:POSIX file, «class cfol»:«class cfol», file:file ¬
	, script:script, constant:yes}
--------------------------------------------------------------------------------
# HANDLERS & SCRIPT OBJECTS:
# domain
#   Determines whether the +object passed is an AppleScript or cocoa object,
#   returning `current application` in the latter case
on domain for object
	local object
	
	if class of object's class = class ¬
		then return AppleScript
	
	this
end domain

# make
#   Creats a new instance of an +object of the specified +_class.  For cocoa
#   objects, a specific instance method is used as declared in the property
#   +instanceMethods
to make new _class with data object
	local _class, object
	
	try
		return run script "on run {object}
		return the object as " & _class & "
		end run" with parameters {object}
	end try
	
	if class of _class = text then set _class ¬
		to NSClassFromString(_class) of this
	
	tell NSExpression
		set arg to expressionForConstantValue_(object)
		set target to expressionForConstantValue_(_class)
		(NSDictionary's dictionaryWithDictionary:SEL)'s ¬
			objectForKey:(NSStringFromClass(_class) ¬
				of this)
		return (its expressionForFunction:target ¬
			selectorName:result arguments:[arg])'s ¬
			expressionValueWithObject:nil context:nil
	end tell
end make

# classOf()
#   Returns the class of an +object
on classOf(object)
	local object
	
	if (domain for object) = AppleScript ¬
		then return the object's class
	
	NSStringFromClass(object's class) of this as text
end classOf

# mainClass
#   For AppleScript objects, this simply returns its class.  For cocoa objects
#   that are NSObjects, the main superclass under NSObject is returned.
on mainClass for object
	local object
	
	if (domain for object) = AppleScript ¬
		then return the object's class
	
	set super to the object's superclass()
	if super = missing value then return "NSObject"
	if "NSObject" = classOf(super) then return classOf(object)
	mainClass for super
end mainClass

# NSClass
#   Returns the equivalent cocoa class to which an AppleScript value bridges
to NSClass for object
	NSCoercion's sharedCoercionHandler()'s coerceValue:object toClass:nil
	mainClass for result
end NSClass


property toString : "UTCreateStringForOSType"
property fromString : "UTGetOSTypeFromString"

# OSType()
#   Converts to and from a four-character AppleEvent type code and its byte
#   value.  +fn can be either of the properties +toString or +fromSring.
#   +arg is passed either a four-character code or an integer value.
on OSType(fn, arg as text)
	local fn, arg
	
	run script "ObjC.import('CoreServices');
	            ObjC.unwrap($." & fn & ¬
		"(" & arg's quoted form & ¬
		"));" in "JavaScript"
end OSType
--------------------------------------------------------------------------------
# COERCION HANDLERS:
# Most of the handlers below should be able to accept AppleScript and cocoa
# objects, returning the class of object indicated by the name of the handler
to __NSString__(str)
	(NSString's stringWithString:str)'s ¬
		stringByStandardizingPath()
end __NSString__

to __NSURL__(|url|)
	if the |URL|'s first character ¬
		is in ["/", "~", "."] ¬
		then return NSURL's ¬
		fileURLWithPath:__NSString__(|url|)
	
	NSURL's URLWithString:|url|
end __NSURL__

to __NSArray__(obj)
	try
		obj's allObjects()
	on error
		obj
	end try
	NSArray's arrayWithArray:result
end __NSArray__

to __NSDict__(obj)
	NSDictionary's dictionaryWithDictionary:obj
end __NSDict__

to __NSSet__(obj)
	NSSet's setWithArray:__NSArray__(obj)
end __NSSet__

to __any__(obj)
	(__NSArray__([obj]) as list)'s item 1
end __any__

to __class__(obj)
	try
		class obj
	on error
		obj
	end try
	
	tell classOf(result)
		if its class ≠ class then return NSClassFromString(it) of this
		if it = class then return obj
	end tell
	
	try
		tell (run script obj)
			if its class = class then return it
			return its class
		end tell
	end try
	
	obj's class
end __class__

to __NSClass__(obj)
	tell __class__(obj)
		if its class ≠ class then return it
		it
	end tell
	
	run script "on run {templates}
	" & result & " in templates
	item 1 of (result as list & {{}})
	end run" with parameters {PRO}
	
	__class__(NSClass for result)
end __NSClass__

# __string__()
#   Returns a string representation of an object
to __string__(object)
	local obj
	
	if the object's class = text then return the object
	
	try
		set s to {_:object} as null
	on error E
		set tid to my text item delimiters
		set my text item delimiters to {"Can’t make {_:"}
		set s to text items 2 thru -1 of E as text
		
		set my text item delimiters to {"} into type null."}
		set s to text items 1 thru -2 of s as text
		
		set my text item delimiters to tid
	end try
	
	s
end __string__

to __bool__(x)
	local x
	
	try
		return x as boolean
	end try
	
	-- Recurse through lists and sum their boolean values
	if x = {} then return false
	if x's class = list then return ¬
		__bool__(x's first item) or ¬
		__bool__(the rest of x)
	
	-- Handle file paths (test for existence)
	if x's class = alias then return true
	if x's class = «class furl» then try
		x as alias
		return true
	on error
		return false
	end try
	
	-- Script objects & handlers
	if x's class = script then return __bool__(run x)
	if x's class = handler then
		script
			property fn : x
		end script
		
		__bool__(result's fn())
	end if
	
	x is not in ["", 0, no, false, null, missing value] and ¬
		x's class is in [¬
		string, text, ¬
		integer, real, number, data, ¬
		boolean, constant, anything, ¬
		class, null, missing value, reference]
end __bool__

to __number__(x)
	local x
	
	try
		__bool__(x) as {number, integer}
	on error
		x
	end try
end __number__
---------------------------------------------------------------------------❮END❯