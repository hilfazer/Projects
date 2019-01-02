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
	registerCommand( "loadLevel", {
		'description' : "unloads current level",
		'args':[ ['levelName', TYPE_STRING] ],
		'target' : [self, "loadLevel"]
	} )


func unloadLevel():
	var result = get_parent().m_levelLoader.unloadLevel()
	if result is GDScriptFunctionState:
		result = yield( result, "completed" )


func loadLevel( levelName : String ):
	var filepathTemplate = "res://levels/%s.tscn"
	var levelFilename = filepathTemplate % levelName

	var result = get_parent().m_levelLoader.loadLevel(
		levelFilename, get_parent().m_currentLevelParent )
	if result is GDScriptFunctionState:
		result = yield( result, "completed" )

	if result != OK:
		Console.Log.warn( "Failed to load level [b]%s[/b]." % levelFilename )
