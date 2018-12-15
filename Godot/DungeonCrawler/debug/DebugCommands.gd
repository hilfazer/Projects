extends Node

const RemoteCallerGd         = preload("res://network/RemoteCaller.gd")
const LoggingRemoteCallerGd  = preload("res://network/LoggingRemoteCaller.gd")


func _ready():
	_registerCommands()


func _registerCommands():
	pass

	var setRpcLog = "setRpcLog"
	Console.register(setRpcLog, {
		'description' : "sets logging RPCs",
		'args':[ ['logEnabled', TYPE_BOOL] ],
		'target' : [self, setRpcLog]
	} )
	connect( "tree_exiting", Console, "deregister", [setRpcLog] )
	

func setRpcLog( logEnabled ):
	if logEnabled:
		Network.setRemoteCaller( LoggingRemoteCallerGd.new( Network.get_tree() ) )
	else:
		Network.setRemoteCaller( RemoteCallerGd.new( Network.get_tree() ) )


