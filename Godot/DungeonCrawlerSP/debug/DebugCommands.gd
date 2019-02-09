extends "res://debug/CommandHolder.gd"


func _registerCommands():
	registerCommand( "setRpcLog", {
		'description' : "sets logging RPCs",
		'args':[ ['logEnabled', TYPE_BOOL] ],
		'target' : [self, "setRpcLog"]
	} )
	registerCommand( "setLogLevel", {
		'description' : "sets debug logging level",
		'args':[ ['level', TYPE_INT] ],
		'target' : [self, "setLogLevel"]
	} )


func setLogLevel( level : int ):
	Debug.setLogLevel( level )

