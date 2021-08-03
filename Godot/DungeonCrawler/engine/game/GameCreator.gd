extends Node


const SavingModuleGd         = preload("res://engine/SavingModule.gd")
const SerializerGd           = preload("res://projects/Serialization/HierarchicalSerializer.gd")
const LevelLoaderGd          = preload("./LevelLoader.gd")
const PlayerAgentGd          = preload("res://engine/agent/PlayerAgent.gd")
const UnitCreationDataGd     = preload("res://engine/units/UnitCreationData.gd")
const FogOfWarGd             = preload("res://engine/level/FogOfWar.gd")

var _game : Node
var _levelLoader : LevelLoaderGd       setget deleted
var _currentLevelParent : Node


signal createFinished( error )


func deleted(_a):
	assert(false)


func initialize( gameScene : Node, currentLevelParent : Node ):
	_game = gameScene
	_currentLevelParent = currentLevelParent
	_levelLoader = LevelLoaderGd.new( gameScene )


func createFromModule( module : SavingModuleGd, unitsCreationData : Array ) -> int:
	assert( _game._module == null )
	_game.setCurrentModule( module )

	var result = yield( _create( unitsCreationData ), "completed" )
	emit_signal( "createFinished", result )
	return result


func createFromFile( filePath : String ):
	yield( get_tree(), "idle_frame" )

	var module : SavingModuleGd = _game._module
	if not module:
		var result = _createNewModule( filePath )
		if result != OK:
			Debug.error( self, "Could not create module from %s" % filePath )
			return result
	else:
		assert( module.moduleMatches( filePath ) )
		module.loadFromFile( filePath )

	var result = yield( _create( [] ), "completed" )
	if result != OK:
		return result

# warning-ignore:return_value_discarded
	SerializerGd.new().deserialize( _game._module.getPlayerData(), _game._playerManager )

	return result


func unloadCurrentLevel():
	yield(_levelLoader.unloadLevel(), "completed")


func loadLevel( levelName : String, withState := true ) -> int:
	var levelState = _game._module.loadLevelState( levelName, true ) \
		if withState \
		else null

	yield(_loadLevel( levelName, levelState ), "completed")
	return OK


func _create( unitsCreationData : Array ) -> int:
	yield( get_tree(), "idle_frame" )

	assert( _game._module )
	assert( get_tree().paused )

	var module : SavingModuleGd = _game._module
	var levelName = module.getCurrentLevelName()
	var levelState = module.loadLevelState( levelName, true )
	yield( _loadLevel( levelName, levelState ), "completed" )

	var entranceName = module.getLevelEntrance( levelName )
	if not entranceName.empty() and not unitsCreationData.empty():
		_createAndInsertUnits( unitsCreationData, entranceName )

	return OK


func _loadLevel( levelName : String, levelState = null ):
	yield( get_tree(), "idle_frame" )

	var filePath = _game._module.getLevelFilename( levelName )
	if filePath.empty():
		return ERR_CANT_CREATE

	var result = yield( _levelLoader.loadLevel(
		filePath, _currentLevelParent ), "completed" )

	if result != OK:
		return result

	_game.currentLevel.applyFogToLevel( FogOfWarGd.TileType.Fogged )

	if levelState != null:
# warning-ignore:return_value_discarded
		SerializerGd.new().deserialize( levelState, _currentLevelParent )

	return OK


func _createNewModule( filePath : String ) -> int:
	assert( _game._module == null )
	assert( _game.currentLevel == null )

	var module = SavingModuleGd.createFromSaveFile( filePath )
	if not module:
		Debug.error( null, "Could not load game from file %s" % filePath )
		return ERR_CANT_CREATE
	else:
		_game.setCurrentModule( module )
	return OK


func _createAndInsertUnits( playerUnitData : Array, entranceName : String ):
	var playerUnits__ = _createPlayerUnits__( playerUnitData )
	_game._playerManager.setPlayerUnits( playerUnits__ )

	var unitNodes : Array = _game._playerManager.getPlayerUnits()

	var notAdded = _levelLoader.insertPlayerUnits( unitNodes, _game.currentLevel, entranceName )
	for unit in notAdded:
		Debug.info(self, "Unit '%s' not added to level" % unit.name)


func _createPlayerUnits__( unitsCreationData : Array ) -> Array:
	var playerUnits__ := []
	for unitData in unitsCreationData:
		assert( unitData is UnitCreationDataGd )
		var fileName = _game._module.getUnitFilename( unitData.name )
		if fileName.empty():
			continue

		var unitNode__ : UnitBase = load( fileName ).instance()
		unitNode__.set_name( "player_%s" % [unitData.name] )

		playerUnits__.append( unitNode__ )
	return playerUnits__
