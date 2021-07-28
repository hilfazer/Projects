extends "res://debug/CommandHolder.gd"

const DebugGd                = preload("res://debug/Debug.gd")

var _debug : DebugGd

func _ready():
	_debug = get_parent()


func _registerCommands():
	registerCommand(
		"setLogLevel",
		"sets debug logging level",
		[ ['level', TYPE_INT] ]
		)

	registerCommand(
		"setLogToConsole",
		"enables/disables logging to console",
		[ ['enabled', TYPE_BOOL] ]
		)

	registerCommand(
		"setLogToFile",
		"enables/disables logging to file",
		[ ['enabled', TYPE_BOOL] ]
		)


func setLogLevel( level : int ):
	Debug.setLogLevel( level )


func setLogToConsole( doLog : bool ):
	_debug.setLogToConsole( doLog )


func setLogToFile( doLog : bool ):
	_debug.setLogToFile( doLog )
