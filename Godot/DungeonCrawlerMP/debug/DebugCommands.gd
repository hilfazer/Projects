extends "res://debug/CommandHolder.gd"

const RemoteCallerGd         = preload("res://core/network/RemoteCaller.gd")
const LoggingRemoteCallerGd  = preload("res://core/network/LoggingRemoteCaller.gd")


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
		Network.setRemoteCaller( LoggingRemoteCallerGd.new() )
	else:
		Network.setRemoteCaller( RemoteCallerGd.new() )


func setLogLevel( level : int ):
	Debug.setLogLevel( level )

