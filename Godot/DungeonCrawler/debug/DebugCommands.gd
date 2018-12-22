extends Node

const RemoteCallerGd         = preload("res://network/RemoteCaller.gd")
const LoggingRemoteCallerGd  = preload("res://network/LoggingRemoteCaller.gd")

var m_commands : Array


func _ready():
	_registerCommands()
	
	
func _exit_tree():
	for command in m_commands:
		Console.deregister( command )


func _registerCommands():
	pass

	var setRpcLog = "setRpcLog"
	Console.register(setRpcLog, {
		'description' : "sets logging RPCs",
		'args':[ ['logEnabled', TYPE_BOOL] ],
		'target' : [self, setRpcLog]
	} )
	m_commands.append( setRpcLog )
	
	var setLogLevel = "setLogLevel"
	Console.register(setLogLevel, {
		'description' : "sets debug logging level",
		'args':[ ['level', TYPE_INT] ],
		'target' : [self, setLogLevel]
	} )
	m_commands.append( setLogLevel )
	

func setRpcLog( logEnabled : bool ):
	if logEnabled:
		Network.setRemoteCaller( LoggingRemoteCallerGd.new( Network.get_tree() ) )
	else:
		Network.setRemoteCaller( RemoteCallerGd.new( Network.get_tree() ) )


func setLogLevel( level : int ):
	Debug.setLogLevel( level )
	
