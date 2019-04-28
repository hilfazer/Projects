extends "res://debug/CommandHolder.gd"

const GameSceneGd            = preload("./GameScene.gd")


func _ready():
	assert( get_parent() is GameSceneGd )


func _registerCommands():
	registerCommand( "unloadLevel",
	{
		'description' : "unloads current level",
		'target' : [self, "unloadLevel"]
	} )
	registerCommand( "loadLevel",
	{
		'description' : "loads a level",
		'args':[ ['levelName', TYPE_STRING] ],
		'target' : [self, "loadLevel"]
	} )
	registerCommand( "addUnitToPlayer",
	{
		'description' : "unloads current level",
		'args':[ ['unitName', TYPE_STRING] ],
		'target' : [self, "addUnitToPlayer"]
	} )
	registerCommand( "removeUnitFromPlayer",
	{
		'description' : "unloads current level",
		'args':[ ['unitName', TYPE_STRING] ],
		'target' : [self, "removeUnitFromPlayer"]
	} )


func unloadLevel():
	get_parent().unloadCurrentLevel()


func loadLevel( levelName : String ):
	if levelName.empty():
		Console.Log.warn( "Level name can't be empty" )
		return

	var game = get_parent()
	if game._module == null:
		yield( get_tree(), "idle_frame" )
		return

	var result = yield( game.loadLevel( levelName ), "completed" )
	if result != OK:
		Console.Log.warn( "Failed to load level [b]%s[/b]." % levelName )


func addUnitToPlayer( unitName : String ):
	if unitName.empty():
		Console.Log.warn( "Unit name can't be empty" )
		return

	var game = get_parent()

	if not is_instance_valid( game.currentLevel ):
		Console.Log.warn( "No current level" )
		return

	var unitNode = game.currentLevel.getUnit( unitName )
	if unitNode == null:
		return

	game._playerManager.addPlayerUnits( [unitNode] )


func removeUnitFromPlayer( unitName : String ):
	if unitName.empty():
		Console.Log.warn( "Unit name can't be empty" )
		return

	var game = get_parent()

	if not is_instance_valid( game.currentLevel ):
		Console.Log.warn( "No current level" )
		return

	var unitNode = game.currentLevel.getUnit( unitName )
	if unitNode == null:
		return

	game._playerManager.removePlayerUnits( [unitNode] )


