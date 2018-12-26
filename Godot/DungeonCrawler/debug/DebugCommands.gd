extends "res://debug/CommandHolder.gd"

const RemoteCallerGd         = preload("res://network/RemoteCaller.gd")
const LoggingRemoteCallerGd  = preload("res://network/LoggingRemoteCaller.gd")


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


func setRpcLog( logEnabled : bool ):
	if logEnabled:
		Network.setRemoteCaller( LoggingRemoteCallerGd.new( Network.get_tree() ) )
	else:
		Network.setRemoteCaller( RemoteCallerGd.new( Network.get_tree() ) )


func setLogLevel( level : int ):
	Debug.setLogLevel( level )

