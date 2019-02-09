extends "res://debug/CommandHolder.gd"

const GameSceneGd            = preload("./GameScene.gd")


func _ready():
	assert( get_parent() is GameSceneGd )


func _registerCommands():
	if not is_network_master():
		return

	registerCommand( "unloadLevel", {
		'description' : "unloads current level",
		'target' : [self, "unloadLevel"]
	} )
	registerCommand( "loadLevel", {
		'description' : "loads a level",
		'args':[ ['levelName', TYPE_STRING] ],
		'target' : [self, "loadLevel"]
	} )


func unloadLevel():
	get_parent().unloadCurrentLevel()


func loadLevel( levelName : String ):
	var game = get_parent()
	if game.m_module == null:
		yield( get_tree(), "idle_frame" )
		return

	var result = yield( game.loadLevel( levelName ), "completed" )
	if result != OK:
		Console.Log.warn( "Failed to load level [b]%s[/b]." % levelName )
