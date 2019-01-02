extends "res://debug/CommandHolder.gd"

const GameSceneGd            = preload("res://game/GameScene.gd")


func _ready():
	assert( get_parent() is GameSceneGd )


func _registerCommands():
	if not is_network_master():
		return

	registerCommand( "unloadLevel", {
		'description' : "unloads current level",
		'target' : [self, "unloadLevel"]
	} )


func unloadLevel():
	var result = get_parent().m_levelLoader.unloadLevel()
	if result is GDScriptFunctionState:
		result = yield( result, "completed" )
