extends Node

const GameSceneGd            = preload("res://game/GameScene.gd")


func _ready():
	assert( get_parent() is GameSceneGd )
#	_registerCommands()


func _registerCommands():
	if not is_network_master():
		return

	var unloadLevel = "unloadLevel"
	Console.register(unloadLevel, {
		'description' : "unloads current level",
		'target' : [get_parent(), unloadLevel]
	} )
	connect( "tree_exiting", Console, "deregister", [unloadLevel] )
