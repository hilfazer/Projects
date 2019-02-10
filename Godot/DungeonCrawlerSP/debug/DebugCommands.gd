extends "res://debug/CommandHolder.gd"


func _registerCommands():
	registerCommand( "setLogLevel", {
		'description' : "sets debug logging level",
		'args':[ ['level', TYPE_INT] ],
		'target' : [self, "setLogLevel"]
	} )


func setLogLevel( level : int ):
	Debug.setLogLevel( level )

