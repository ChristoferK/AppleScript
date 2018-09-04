#!/usr/bin/osascript
--------------------------------------------------------------------------------
###[ASObjC] Get Calendar Events.applescript
#
#	Retrieves events from a user's Apple Calendar that fall within a
#	specified date range.  It does this independently of the calendar 
#	application, using AppleScriptObjC.
#
#  Input:
#	％input％			Either a single date or pair of dates 
#					that represent a range of dates between 
#					which events are searched
#
#  Result:
#	❮list❯				A list of events that are scheduled to
#					fall on or between the given dates
--------------------------------------------------------------------------------
#  Author: CK
#  Date Created: 2018-09-01
#  Date Last Edited: 2018-09-04
--------------------------------------------------------------------------------
use framework "Foundation"
use framework "EventKit"
use scripting additions
--------------------------------------------------------------------------------
property this : a reference to current application
property EKAuthorizationStatusAuthorized : a reference to 3
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
property NSString : a reference to NSString of this
property NSTimeZone : a reference to NSTimeZone of this
--------------------------------------------------------------------------------
global EventStore, EventSources, calendars
--------------------------------------------------------------------------------
###IMPLEMENTATION
#
#
on run input
	if input's class = script then set the input to [current date]
	if input's length = 1 then set input to input's [item 1, item 1]
	set [fromDate, toDate] to the input
	if toDate's class ≠ date then set toDate to fromDate -- for Automator
	
	set EventStore to EKEventStore's alloc()'s init()
	if not isAuthorised() then return ¬
		"Require authorisation to access calendar events"
	
	set EventSources to NSMutableArray's alloc()'s init()
	repeat with source in EventStore's sources()
		(EventSources's addObject:(NSArray's ¬
			arrayWithArray:(source's [¬
				title(), ¬
				sourceType(), ¬
				sourceIdentifier()])))
	end repeat
	
	set calendars to (EventStore's calendarsForEntityType:EKEntityTypeEvent)
	
	eventsInDateRange from "2018-01-01" to toDate
end run
--------------------------------------------------------------------------------
###HANDLERS
#
#
on isAuthorised()
	global EventStore
	
	EventStore's requestAccessToEntityType:EKEntityMaskEvent ¬
		completion:(missing value)
	EKEventStore's authorizationStatusForEntityType:EKEntityMaskEvent
	if the result ≠ EKAuthorizationStatusAuthorized then return false
	
	true
end isAuthorised

# dateAsDateRange_():
#	Returns a list whose first item and second item are evaluate to midnight
#	and 23:59:59, respectively, of the specified date.  The input can be an
#	AppleScript date object or a string value formatted "yyyy-MM-dd", which
#	yield list items of the return value that are, respectively, either 
#	AppleScript or Cocoa NSDate objects.
on dateAsDateRange:input
	local input
	
	if input's class = date then
		tell the input to copy ¬
			[0, it, 86399, it] to ¬
			[time, startDate, time, endDate]
		{startDate:startDate, endDate:endDate}
	else
		set DateFormatter to NSDateFormatter's alloc()'s init()
		DateFormatter's setLocale:(NSLocale's ¬
			localeWithLocaleIdentifier:"en_US_POSIX")
		DateFormatter's setTimeZone:(NSTimeZone's ¬
			timeZoneForSecondsFromGMT:0)
		DateFormatter's setDateFormat:"yyyy-MM-dd"
		NSDateInterval's alloc()'s initWithStartDate:(DateFormatter's ¬
			dateFromString:input) duration:86399
	end if
	
	{startDate:result's startDate, endDate:result's endDate}
end dateAsDateRange:

on eventsInDateRange from startDate to endDate
	local startDate, endDate
	global EventStore, calendars
	
	set startDate to (my dateAsDateRange:startDate)'s startDate
	set endDate to (my dateAsDateRange:endDate)'s endDate
	set eventsInDateRange to EventStore's ¬
		predicateForEventsWithStartDate:startDate ¬
			endDate:endDate ¬
			calendars:calendars
	
	set eventsSearchResults to NSMutableArray's alloc()'s init()
	
	repeat with |Event| in the (EventStore's ¬
		eventsMatchingPredicate:eventsInDateRange)
		|Event|'s {calender:calendar()'s title() ¬
			, |name|:title() ¬
			, location:location() ¬
			, notes:notes() ¬
			, start:startDate() ¬
			, finish:endDate() ¬
			, allDay:allDay()}
		(eventsSearchResults's addObject:result)
	end repeat
	
	return the eventsSearchResults as list
end eventsInDateRange