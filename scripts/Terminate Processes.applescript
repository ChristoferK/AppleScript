#!/usr/bin/osascript
--------------------------------------------------------------------------------
# pnam: TERMINATE PROCESSES
# nmxt: .applescript
# pDSC: Presents a list of running processes for termination

# plst: -

# rslt: - Processes terminate
--------------------------------------------------------------------------------
# sown: CK
# ascd: 2018-09-17
# asmo: 2019-05-12
--------------------------------------------------------------------------------
use framework "Foundation"
use scripting additions

property this : a reference to the current application
property NSPredicate : a reference to NSPredicate of this
property NSSortDescriptor : a reference to NSSortDescriptor of this
property NSWorkspace : a reference to NSWorkspace of this

property Workspace : a reference to NSWorkspace's sharedWorkspace

property key : "localizedName"
--------------------------------------------------------------------------------
# IMPLEMENTATION:
set A to Workspace()'s runningApplications()'s sortedArrayUsingDescriptors:[¬
	NSSortDescriptor's sortDescriptorWithKey:key ascending:yes ¬
	selector:"caseInsensitiveCompare:"]

tell {} & (choose from list A's localizedName as list ¬
	with title ["Running Processes"] ¬
	with prompt ["Select processes to kill:"] OK button name ["Quit"] ¬
	with multiple selections allowed without empty selection allowed) ¬
	to set procs to A's filteredArrayUsingPredicate:(NSPredicate's ¬
	predicateWithFormat_(my key & " IN %@", it))

repeat with proc in procs
	# proc's terminate()
	proc's forceTerminate()
end repeat
---------------------------------------------------------------------------❮END❯