extends Node

const ModuleGd               = preload("res://core/Module.gd")
const SavingModuleGd         = preload("res://core/SavingModule.gd")
const SerializerGd           = preload("res://core/Serializer.gd")
const UtilityGd              = preload("res://core/Utility.gd")
const PlayerUnitGd           = preload("./PlayerUnit.gd")
const LevelLoaderGd          = preload("./LevelLoader.gd")


var m_game                             setget deleted
var m_levelLoader : LevelLoaderGd      setget deleted


signal createFinished( error )


func deleted(_a):
	assert(false)


func setGame( game : Node ):
	m_game = game
	m_levelLoader = LevelLoaderGd.new( game )


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


func _createAndInsertUnits( playerUnitData : Array, entranceName : String ):
	var playerUnits = _createPlayerUnits( playerUnitData )
	m_game.m_playerManager.setPlayerUnits( playerUnits )

	var unitNodes : Array = []
	for playerUnit in m_game.m_playerManager.m_playerUnits:
		unitNodes.append( playerUnit.m_unitNode_ )

	m_levelLoader.insertPlayerUnits( unitNodes, m_game.m_currentLevel, entranceName )


func _createPlayerUnits( unitsCreationData : Array ) -> Array:
	var playerUnits : Array = []
	for unitDatum in unitsCreationData:
		assert( unitDatum is Dictionary )
		var fileName = m_game.m_module.getUnitFilename( unitDatum.name )
		if fileName.empty():
			continue

		var unitNode_ = load( fileName ).instance()
		unitNode_.set_name( str( Network.m_clients[unitDatum.owner] ) + "_" )
		unitNode_.setNameLabel( Network.m_clients[unitDatum.owner] )

		var playerUnit : PlayerUnitGd = PlayerUnitGd.new( unitNode_, unitDatum.owner )
		playerUnits.append( playerUnit )
	return playerUnits


func _clearGame():
	yield( get_tree(), "idle_frame" )
	m_game.m_playerManager.removePlayerUnits()
	if m_game.m_currentLevel != null:
		yield( m_levelLoader.unloadLevel(), "completed" )
	if m_game.m_module:
		m_game.setCurrentModule( null )


static func makeUnitDatum():
	return { name = "", owner = 0 }
