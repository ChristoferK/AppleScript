#!/usr/bin/osascript
--------------------------------------------------------------------------------
###[ASObjC] Get Calendar Events.applescript
#
#	Retrieves from a user's Apple Calendar an enumerated list of events 
#	that fall within a specified date range.  It does this independently of
#	the macOS calendar application, using AppleScriptObjC.  By default, 
#	events for the next 30 days are searched, and the title and date of the
#	next upcoming event is returned.  If no events occur within this time
#	span, an empty list is returned.
#
#  Input:
#	％input％			Either a single date or pair of dates 
#					that represent a range of dates between 
#					which events are searched
#
#  Result:
#	-1				Authorisation required
#	❮string❯			The details of the next event, if any,
#					to fall on or between the given dates
#	❮empty list❯			No upcoming events
--------------------------------------------------------------------------------
#  Author: CK
#  Date Created: 2018-09-01
#  Date Last Edited: 2018-09-23
--------------------------------------------------------------------------------
use framework "Foundation"
use framework "EventKit"
use scripting additions
--------------------------------------------------------------------------------
property this : a reference to current application
property EKAuthorised : a reference to 3
property EKEntityMaskEvent : a reference to EKEntityMaskEvent of this
property EKEntityTypeEvent : a reference to EKEntityTypeEvent of this
property EKEventStore : a reference to EKEventStore of this
property NSArray : a reference to NSArray of this
property NSDate : a reference to NSDate of this
property NSDateFormatter : a reference to NSDateFormatter of this
property NSDateInterval : a reference to NSDateInterval of this
property NSLocale : a reference to NSLocale of this
property NSMutableArray : a reference to NSMutableArray of this
property NSPredicate : a reference to NSPredicate of this
property NSSortDescriptor : a reference to NSSortDescriptor of this
property NSString : a reference to NSString of this
property NSTimeZone : a reference to NSTimeZone of this
--------------------------------------------------------------------------------
property EventStore : a reference to EKEventStore's alloc's init
property EventSources : a reference to EventStore's sources

global calendars
--------------------------------------------------------------------------------
property text item delimiters : space
property |24hours| : 86399
--------------------------------------------------------------------------------
###IMPLEMENTATION
#
#
# e.g. input: {"2018-01-01", current date}
on run input
	if not Authorised() then return -1
	
	if input's class = script then set the input to [current date, ¬
		(current date) + 30 * days] -- A one-month time span
	set [D1, D2] to the input
	if D2's class is record then set [D1, D2] to D1 -- Automator
	
	set calendars to EventStore's calendarsForEntityType:EKEntityTypeEvent
	
	tell (enumeratedEventsByDate from D1 to D2 with birthdays) to if ¬
		(its nextEvent() ≠ null) then tell its currentEvent() to ¬
		return the contents of {"Next Event:", its title, ¬
			"on", its startDate's short date string, ¬
			"at", its startDate's time string} as text
	{}
end run
--------------------------------------------------------------------------------
###HANDLERS
#
#
on Authorised()
	EventStore's requestAccessToEntityType:EKEntityMaskEvent ¬
		completion:(missing value)
	EKEventStore's authorizationStatusForEntityType:EKEntityMaskEvent
	if the result ≠ EKAuthorised then return false
	
	true
end Authorised

# dateRange:
#	Returns a list whose first and second items are AppleScript date objects 
#	that evaluate to midnight and 23:59:59, respectively, on the specified
#	date.  The input can be an AppleScript date object or a string value 
#	formatted as "yyyy-MM-dd".
on dateRange over D
	local D
	
	if D's class = date then
		script
			property date : D - (D's time)
			
			on startDate()
				my date
			end startDate
			
			on endDate()
				(my date) + |24hours|
			end endDate
		end script
	else
		set DateFormatter to NSDateFormatter's alloc()'s init()
		
		tell the DateFormatter
			setLocale_(NSLocale's ¬
				localeWithLocaleIdentifier:"en_US_POSIX")
			setTimeZone_(NSTimeZone's timeZoneForSecondsFromGMT:0)
			setDateFormat_("yyyy-MM-dd")
			NSDateInterval's alloc()'s ¬
				initWithStartDate:dateFromString_(D) ¬
					duration:|24hours|
		end tell
	end if
	
	tell result to return [startDate() as date, endDate() as date]
end dateRange

# enumeratedEventsByDate:
#	Searches for events that fall between the dates supplied, with the
#	option to include or exclude birthday events.  Both date parameters
#	are optional, and will default to the current date if absent.  The
#	handler returns a script object that mimics an enumerated list, which
#	contains the results of the search in date order.  The order is
#	reversed if the date parameters are reversed.
#
#	Iterate through the event list using the nextEvent() or 
#	nextEventMatching handlers, the latter of which returns the next
#	event that contains any matching parameter supplied.  currentEvent()
#	allows retrieval of the event at the current position in the list
#	without advancing to the next event.  allEvents() returns the list
#	of events in one go.
#
#	Each event is a record object containing the following properties:
#	title, startDate, endDate, location, notes.
on enumeratedEventsByDate from D1 : null to D2 : null without birthdays
	local D1, D2, birthdays
	local ascending
	global calendars
	
	if D1 = null then set D1 to the current date
	if D2 = null then set D2 to the current date
	
	set [D1, D2] to [dateRange over D1, dateRange over D2]
	
	set ascending to D1's item 1 < D2's item 1
	if not ascending then set [D1, D2] to [D2, D1]
	set [D1, D2] to [item 1 of D1, item 2 of D2]
	
	EventStore's predicateForEventsWithStartDate:D1 endDate:D2 ¬
		calendars:calendars
	EventStore's eventsMatchingPredicate:result
	set eventsInDateRange to NSMutableArray's arrayWithArray:result
	
	NSPredicate's predicateWithFormat:("! calendar.title CONTAINS[c] %@") ¬
		argumentArray:["birthdays"]
	if not birthdays then eventsInDateRange's filterUsingPredicate:result
	
	eventsInDateRange's sortUsingDescriptors:[¬
		NSSortDescriptor's sortDescriptorWithKey:(missing value) ¬
		ascending:ascending selector:"compareStartDateWithEvent:"]
	
	script
		property list : eventsInDateRange
		property event : null
		property all : eventsInDateRange's allObjects() as list
		
		on nextEvent()
			if (my list's |count|()) = 0 then return null
			set E to my list's item 1
			(my list)'s removeObjectAtIndex:0
			
			E's dictionaryWithValuesForKeys:[¬
				"title", ¬
				"startDate", ¬
				"endDate", ¬
				"location", ¬
				"notes"]
			
			set my event to the result as record
		end nextEvent
		
		on currentEvent()
			my event
		end currentEvent
		
		on nextEventMatching given name:title : null ¬
			, date:D : missing value ¬
			, location:addr : null
			
			set E to false
			
			repeat until result = true or E = null
				set E to the nextEvent()
				if E = null then exit repeat
				
				copy [E's startDate, 0] to [D0, D0's time]
				copy [E's endDate, |24hours|] to [D1, D1's time]
				
				true is in [D ≥ D0 and D ≤ D1, ¬
					E's title contains title, ¬
					E's location contains addr]
			end repeat
			
			E
		end nextEventMatching
		
		on allEvents()
			if all = {} then return {}
			if the class of some item in all ≠ record ¬
				then repeat with E in all
				tell E to set its contents to ¬
					dictionaryWithValuesForKeys_([¬
						"title", ¬
						"startDate", ¬
						"endDate", ¬
						"location", ¬
						"notes"]) as record
			end repeat
			
			all
		end allEvents
	end script
end enumeratedEventsByDate
---------------------------------------------------------------------------❮END❯