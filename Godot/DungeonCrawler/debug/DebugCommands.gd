extends "res://debug/CommandHolder.gd"

const DebugGd                = preload("res://debug/Debug.gd")

var _debug : DebugGd

func _ready():
	_debug = get_parent()


func _registerCommands():
	registerCommand( "setLogLevel", {
		'description' : "sets debug logging level",
		'args':[ ['level', TYPE_INT] ],
		'target' : [self, "setLogLevel"]
	} )
	registerCommand( "setLogToConsole", {
		'description' : "enables/disables logging to console",
		'args':[ ['level', TYPE_BOOL] ],
		'target' : [self, "setLogToConsole"]
	} )
	registerCommand( "setLogToFile", {
		'description' : "enables/disables logging to file",
		'args':[ ['level', TYPE_BOOL] ],
		'target' : [self, "setLogToFile"]
	} )


func setLogLevel( level : int ):
	Debug.setLogLevel( level )


func setLogToConsole( doLog : bool ):
	_debug.setLogToConsole( doLog )


func setLogToFile( doLog : bool ):
	_debug.setLogToFile( doLog )
