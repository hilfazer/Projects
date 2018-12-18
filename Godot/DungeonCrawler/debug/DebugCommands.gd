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
	
	var setLogLevel = "setLogLevel"
	Console.register(setLogLevel, {
		'description' : "sets debug logging level",
		'args':[ ['level', TYPE_INT] ],
		'target' : [self, setLogLevel]
	} )
	connect( "tree_exiting", Console, "deregister", [setLogLevel] )
	

func setRpcLog( logEnabled : bool ):
	if logEnabled:
		Network.setRemoteCaller( LoggingRemoteCallerGd.new( Network.get_tree() ) )
	else:
		Network.setRemoteCaller( RemoteCallerGd.new( Network.get_tree() ) )


func setLogLevel( level : int ):
	Debug.setLogLevel( level )
	
