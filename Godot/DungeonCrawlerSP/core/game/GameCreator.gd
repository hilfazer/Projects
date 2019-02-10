extends Node

const SavingModuleGd         = preload("res://core/SavingModule.gd")
const SerializerGd           = preload("res://core/Serializer.gd")
const LevelLoaderGd          = preload("./LevelLoader.gd")

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

	if not m_game.m_module or not m_game.m_module.moduleMatches( filePath ):
		var result = _createNewModule( filePath )
		if result != OK:
			Debug.err( self, "Could not create module from %s" % filePath )
			return result
	else:
		m_game.m_module.loadFromFile( filePath )

	var result = yield( _create( [] ), "completed" )
	return result


func _create( unitsCreationData : Array ) -> int:
	yield( get_tree(), "idle_frame" )

	assert( m_game.m_module )

	var module = m_game.m_module
	var levelName = module.getCurrentLevelName()
	var levelState = module.loadLevelState( levelName, true )
	var result = yield( _loadLevel( levelName, levelState ), "completed" )

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


func _clearGame():
	yield( get_tree(), "idle_frame" )
	if m_game.m_currentLevel != null:
		yield( m_levelLoader.unloadLevel(), "completed" )
	if m_game.m_module:
		m_game.setCurrentModule( null )
