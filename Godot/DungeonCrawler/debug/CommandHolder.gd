extends Node

var m_commands : Array


func _ready():
	_registerCommands()


func _notification( what ):
	match what:
		NOTIFICATION_PREDELETE:
			_deregisterCommands()


func registerCommand( commandName : String, args : Dictionary ):
	var result = Console.register( commandName, args )
	if result == OK:
		m_commands.append( commandName )
	
	return result


func _registerCommands():
	pass


func _deregisterCommands():
	for commandName in m_commands:
		Console.deregister( commandName )
