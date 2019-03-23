extends Node

var _commands : PoolStringArray


func _ready():
	_registerCommands()


func _notification( what ):
	match what:
		NOTIFICATION_PREDELETE:
			_unregisterCommands()


func registerCommand( commandName : String, args : Dictionary ):
	var result = Console.register( commandName, args )
	if result == OK:
		_commands.append( commandName )

	return result


func _registerCommands():
	pass


func _unregisterCommands():
	for commandName in _commands:
		Console.unregister( commandName )
	_commands = []
