#!/usr/bin/osascript
--------------------------------------------------------------------------------
# pnam: QUIT ALL APPS
# nmxt: .applescript
# pDSC: Quits all running applications except those in a predefined "No Quit"
#	exceptions list.

# plst: -

# rslt: Applications terminate
#	�sysonotf� : App-specific error message
--------------------------------------------------------------------------------
# sown: CK
# ascd: 2018-08-08
# asmo: 2018-10-25
--------------------------------------------------------------------------------
property noQuit : {�
	"Alfred 3", �
	"Finder", �
	"Keyboard Maestro Engine", �
	"Little Snitch Agent", �
	"Resilio Sync", �
	"Typinator", �
	"AppCleaner SmartDelete", �
	"ManyCam", �
	"FastScripts"}
--------------------------------------------------------------------------------
# IMPLEMENTATION:
tell application "System Events" to set runningApps to �
	the bundle identifier of application processes where �
	the class of its menu bar contains menu bar and �
	the POSIX path of the application file �
		does not start with "/System" and �
	the POSIX path of the application file �
		does not start with "/Library"

kill(runningApps, noQuit)
--------------------------------------------------------------------------------
# HANDLERS:
to kill(Apps as list, X as list)
	local Apps, X
	
	if Apps = {} then return
	
	script
		property list : Apps
	end script
	
	tell the result's list to set [A, A_] to its [item 1, rest]
	
	try
		tell application id A to if its name is not in X then quit it
	on error E
		display notification E �
			with title my name �
			subtitle name of application id A
	end try
	
	kill(A_, X)
end kill
--------------------------------------------------------------------------:END #