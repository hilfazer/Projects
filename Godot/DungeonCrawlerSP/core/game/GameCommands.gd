extends "res://debug/CommandHolder.gd"

const GameSceneGd            = preload("./GameScene.gd")
const PlayerAgentGd          = preload("res://core/agent/PlayerAgent.gd")

var _playerAgent : PlayerAgentGd


func _ready():
	assert( get_parent() is GameSceneGd )
	yield( get_tree(), "idle_frame" )
	_playerAgent = $"../PlayerManager/PlayerAgent"
	assert( _playerAgent )


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
	registerCommand( "selectPlayerUnit",
	{
		'description' : "selects player's unit",
		'args':[ ['name', TYPE_STRING] ],
		'target' : [self, "selectPlayerUnit"]
	} )
	registerCommand( "deselectPlayerUnit",
	{
		'description' : "deselects player's unit",
		'args':[ ['name', TYPE_STRING] ],
		'target' : [self, "deselectPlayerUnit"]
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


func selectPlayerUnit( unitName : String ):
	var playerUnit : UnitBase
	for unit in get_parent()._playerManager.getUnits():
		if unit.name == unitName:
			playerUnit = unit
			break

	if playerUnit == null:
		Console.Log.warn("No player unit named %s " % [unitName] )
		return

	_playerAgent.selectUnit( playerUnit )


func deselectPlayerUnit( unitName : String ):
	var playerUnit : UnitBase
	for unit in get_parent()._playerManager.getUnits():
		if unit.name == unitName:
			playerUnit = unit
			break

	if playerUnit == null:
		Console.Log.warn("No player unit named %s " % [unitName] )
		return

	_playerAgent.deselectUnit( playerUnit )

