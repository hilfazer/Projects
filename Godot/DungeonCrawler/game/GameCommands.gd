extends "res://debug/CommandHolder.gd"

const GameSceneGd            = preload("res://game/GameScene.gd")


func _ready():
	assert( get_parent() is GameSceneGd )


func _registerCommands():
	if not is_network_master():
		return
		
	registerCommand( "unloadLevel", {
		'description' : "unloads current level",
		'target' : [get_parent(), "unloadLevel"]
	} )
