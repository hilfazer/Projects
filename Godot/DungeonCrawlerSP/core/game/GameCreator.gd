extends Node

const SavingModuleGd         = preload("res://core/SavingModule.gd")
const SerializerGd           = preload("res://core/Serializer.gd")
const LevelLoaderGd          = preload("./LevelLoader.gd")
const PlayerAgentGd          = preload("res://core/agent/PlayerAgent.gd")

const PlayerName = "Player1"

var _game : Node
var _levelLoader : LevelLoaderGd       setget deleted


signal createFinished( error )


func deleted(_a):
	assert(false)


func initialize( gameScene : Node ):
	_game = gameScene
	_levelLoader = LevelLoaderGd.new( gameScene )


func createFromModule( module : SavingModuleGd, unitsCreationData : Array ) -> int:
	assert( _game._module == null )
	_game.setCurrentModule( module )

	var result = yield( _create( unitsCreationData ), "completed" )
	_createPlayerAgent( PlayerName, _game._playerManager.getPlayerUnitNodes() )
	_addFogVisionToPlayerUnits()
	emit_signal( "createFinished", result )
	return result


func createFromFile( filePath : String ):
	yield( _clearGame(), "completed" )

	var module : SavingModuleGd = _game._module
	if not module or not module.moduleMatches( filePath ):
		var result = _createNewModule( filePath )
		if result != OK:
			Debug.err( self, "Could not create module from %s" % filePath )
			return result
	else:
		module.loadFromFile( filePath )

	var result = yield( _create( [] ), "completed" )
	if result != OK:
		return result

	var playerUnits := []
	for playerUnitPath in _game._module.getPlayerUnitsPaths():
		var absPath = str( _game._currentLevel.get_path() ) \
			+ '/' + playerUnitPath
		assert( $'/root'.has_node( absPath ) )
		playerUnits.append( NodeRAII.new( $'/root'.get_node( absPath ) ) )

	_game._playerManager.addPlayerUnits( playerUnits )
	_createPlayerAgent( PlayerName, _game._playerManager.getPlayerUnitNodes() )
	_addFogVisionToPlayerUnits()

	return result


func unloadCurrentLevel():
	var result = yield( _levelLoader.unloadLevel(), "completed" )


func loadLevel( levelName : String, withState := true ) -> int:
	var levelState = _game._module.loadLevelState( levelName, true ) \
		if withState \
		else null

	yield( _loadLevel( levelName, levelState ), "completed" )
	return OK


func _create( unitsCreationData : Array ) -> int:
	yield( get_tree(), "idle_frame" )

	assert( _game._module )
	assert( get_tree().paused )

	var module : SavingModuleGd = _game._module
	var levelName = module.getCurrentLevelName()
	var levelState = module.loadLevelState( levelName, true )
	var result = yield( _loadLevel( levelName, levelState ), "completed" )

	var entranceName = module.getLevelEntrance( levelName )
	if not entranceName.empty() and not unitsCreationData.empty():
		_createAndInsertUnits( unitsCreationData, entranceName )

	return OK


func _loadLevel( levelName : String, levelState = null ):
	var filePath = _game._module.getLevelFilename( levelName )
	if filePath.empty():
		return ERR_CANT_CREATE

	var result = yield( _levelLoader.loadLevel(
		filePath, _game._currentLevelParent ), "completed" )

	if result != OK:
		return result

	_game._currentLevel.applyFogToLevel()

	if levelState != null:
		SerializerGd.deserialize( [levelName, levelState], _game._currentLevelParent )

	return OK


func _createNewModule( filePath : String ) -> int:
	assert( _game._module == null )
	assert( _game._currentLevel == null )

	var module = SavingModuleGd.createFromSaveFile( filePath )
	if not module:
		Debug.err( null, "Could not load game from file %s" % filePath )
		return ERR_CANT_CREATE
	else:
		_game.setCurrentModule( module )
	return OK


func _createAndInsertUnits( playerUnitData : Array, entranceName : String ):
	var playerUnits = _createPlayerUnits( playerUnitData )
	_game._playerManager.setPlayerUnits( playerUnits )

	var unitNodes : Array = []
	for playerUnit in _game._playerManager._playerUnits:
		unitNodes.append( playerUnit.getNode() )

	_levelLoader.insertPlayerUnits( unitNodes, _game._currentLevel, entranceName )


func _createPlayerUnits( unitsCreationData : Array ) -> Array:
	var playerUnits : Array = []
	for unitDatum in unitsCreationData:
		assert( unitDatum is Dictionary )
		var fileName = _game._module.getUnitFilename( unitDatum.name )
		if fileName.empty():
			continue

		var unitNode_ = load( fileName ).instance()
		unitNode_.set_name( "unit_" )

		var playerUnit := NodeRAII.new( unitNode_ )
		playerUnits.append( playerUnit )
	return playerUnits


func _clearGame():
	yield( get_tree(), "idle_frame" )
	if _game._currentLevel != null:
		yield( _levelLoader.unloadLevel(), "completed" )
	if _game._module:
		_game.setCurrentModule( null )
	_game._playerManager.setPlayerUnits( [] )
	_game._playerManager.eraseAgent( PlayerName )


func _addFogVisionToPlayerUnits():
	var playerUnits = _game._playerManager._playerUnits
	for playerUnit in playerUnits:
		_game._currentLevel.addUnitToFogVision( playerUnit.getNode() )


func _createPlayerAgent( agentName : String, units : Array ):
	var agent = PlayerAgentGd.new()
	agent.name = agentName
	_game._playerManager.addAgent( agent )

	for unit in _game._playerManager.getPlayerUnitNodes():
		assert( unit is UnitBase )
		agent.addUnit( unit )
