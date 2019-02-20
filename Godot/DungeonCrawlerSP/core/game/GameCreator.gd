extends Node

const SavingModuleGd         = preload("res://core/SavingModule.gd")
const SerializerGd           = preload("res://core/Serializer.gd")
const LevelLoaderGd          = preload("./LevelLoader.gd")
const NodeRAIIGd             = preload("res://core/NodeRAII.gd")

var m_game : Node
var m_levelLoader : LevelLoaderGd      setget deleted


signal createFinished( error )


func deleted(_a):
	assert(false)


func initialize( gameScene : Node ):
	m_game = gameScene
	m_levelLoader = LevelLoaderGd.new( gameScene )


func createFromModule( module : SavingModuleGd, unitsCreationData : Array ) -> int:
	assert( m_game.m_module == null )
	m_game.setCurrentModule( module )

	var result = yield( _create( unitsCreationData ), "completed" )
	emit_signal( "createFinished", result )
	return result


func createFromFile( filePath : String ):
	yield( _clearGame(), "completed" )

	var module : SavingModuleGd = m_game.m_module
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
	for playerUnitPath in m_game.m_module.getPlayerUnitsPaths():
		var absPath = str( m_game.m_currentLevel.get_path() ) \
			+ '/' + playerUnitPath
		assert( $'/root'.has_node( absPath ) )
		playerUnits.append( NodeRAIIGd.new( $'/root'.get_node( absPath ) ) )

	m_game.m_playerManager.setPlayerUnits( playerUnits )

	return result


func unloadCurrentLevel():
	var result = yield( m_levelLoader.unloadLevel(), "completed" )


func loadLevel( levelName : String, withState := true ) -> int:
	var levelState = m_game.m_module.loadLevelState( levelName, true ) \
		if withState \
		else null

	yield( _loadLevel( levelName, levelState ), "completed" )
	return OK


func _create( unitsCreationData : Array ) -> int:
	yield( get_tree(), "idle_frame" )

	assert( m_game.m_module )

	var module : SavingModuleGd = m_game.m_module
	var levelName = module.getCurrentLevelName()
	var levelState = module.loadLevelState( levelName, true )
	var result = yield( _loadLevel( levelName, levelState ), "completed" )

	var entranceName = module.getLevelEntrance( levelName )
	if not entranceName.empty():
		_createAndInsertUnits( unitsCreationData, entranceName )


	return OK


func _loadLevel( levelName : String, levelState = null ):
	var filePath = m_game.m_module.getLevelFilename( levelName )
	if filePath.empty():
		return ERR_CANT_CREATE

	var result = yield( m_levelLoader.loadLevel(
		filePath, m_game.m_currentLevelParent ), "completed" )

	if result != OK:
		return result

	if levelState != null:
		SerializerGd.deserialize( [levelName, levelState], m_game.m_currentLevelParent )

	return OK


func _createNewModule( filePath : String ) -> int:
	assert( m_game.m_module == null )
	assert( m_game.m_currentLevel == null )

	var module = SavingModuleGd.createFromSaveFile( filePath )
	if not module:
		Debug.err( null, "Could not load game from file %s" % filePath )
		return ERR_CANT_CREATE
	else:
		m_game.setCurrentModule( module )
	return OK


func _createAndInsertUnits( playerUnitData : Array, entranceName : String ):
	var playerUnits = _createPlayerUnits( playerUnitData )
	m_game.m_playerManager.setPlayerUnits( playerUnits )

	var unitNodes : Array = []
	for playerUnit in m_game.m_playerManager.m_playerUnits:
		unitNodes.append( playerUnit.getNode() )

	m_levelLoader.insertPlayerUnits( unitNodes, m_game.m_currentLevel, entranceName )


func _createPlayerUnits( unitsCreationData : Array ) -> Array:
	var playerUnits : Array = []
	for unitDatum in unitsCreationData:
		assert( unitDatum is Dictionary )
		var fileName = m_game.m_module.getUnitFilename( unitDatum.name )
		if fileName.empty():
			continue

		var unitNode_ = load( fileName ).instance()
		unitNode_.set_name( "unit_" )

		var playerUnit := NodeRAIIGd.new( unitNode_ )
		playerUnits.append( playerUnit )
	return playerUnits


func _clearGame():
	yield( get_tree(), "idle_frame" )
	if m_game.m_currentLevel != null:
		yield( m_levelLoader.unloadLevel(), "completed" )
	if m_game.m_module:
		m_game.setCurrentModule( null )
