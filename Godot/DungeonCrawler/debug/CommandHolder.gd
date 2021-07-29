extends Node

var _commands : PoolStringArray


func _ready():
	_registerCommands()


func _notification( what ):
	match what:
		NOTIFICATION_PREDELETE:
			_unregisterCommands()


func registerCommand( commandName :String, description :String, argArray := [], method = null ):
	var command = Console.add_command(commandName, self, method)
	command.set_description(description)

	for arg in argArray:
		assert(arg is Array and arg.size() >= 2)
		command.add_argument(arg[0], arg[1])

	command.register()

	_commands.append(commandName)
	return OK


func _registerCommands():
	pass


func _unregisterCommands():
	for commandName in _commands:
		Console.remove_command( commandName )
	_commands = []
