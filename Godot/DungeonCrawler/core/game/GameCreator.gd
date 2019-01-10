extends Node

const ModuleGd               = preload("res://core/Module.gd")
const SavingModuleGd         = preload("res://core/SavingModule.gd")
const SerializerGd           = preload("res://core/Serializer.gd")
const UtilityGd              = preload("res://core/Utility.gd")
const PlayerUnitGd           = preload("./PlayerUnit.gd")


var m_game                             setget deleted


signal createFinished( error )


func deleted(_a):
	assert(false)


func setGame( game : Node ):
	m_game = game


func _loadlevel( filePath : String, levelName, levelState = null ):
	var result = m_game.m_levelLoader.loadLevel(
		filePath, m_game.m_currentLevelParent )
	if result is GDScriptFunctionState:
		result = yield( result, "completed" )

	if result != OK:
		return result

	if levelState != null:
		SerializerGd.deserialize( [levelName, levelState], m_game.m_currentLevelParent )

	return OK


func _createPlayerUnits( unitsCreationData : Array ) -> Array:
	assert( is_network_master() )

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


static func makeUnitDatum():
	return { name = "", owner = 0 }
