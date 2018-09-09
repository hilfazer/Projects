extends Node

const SavingModuleGd         = preload("res://modules/SavingModule.gd")
const UtilityGd              = preload("res://Utility.gd")

var m_game                             setget deleted
var m_module                           setget setModule
var m_playerUnitsCreationData = []     setget setPlayerUnitsCreationData
var m_playersIds = []                  setget setPlayersIds


signal finished


func deleted(a):
	assert(false)


func _init( game ):
	m_game = game
	name = "GameCreator"


func setModule( module ):
	m_module = module


func setPlayerUnitsCreationData( data ):
	m_playerUnitsCreationData = data


func setPlayersIds( ids ):
	m_playersIds = ids


func prepare():
	assert( is_inside_tree() )
	assert( is_network_master() )
	assert( m_game.m_currentLevel == null )

	var levelFilename = m_module.getStartingLevelFilenameAndEntrance()[0]
	var levelEntrance = m_module.getStartingLevelFilenameAndEntrance()[1]

	m_game.createPlayerUnits( m_playerUnitsCreationData )
	m_game.loadLevel( levelFilename )
	m_game.m_levelLoader.insertPlayerUnits( \
		m_game.getPlayerUnits(), m_game.m_currentLevel, levelEntrance )

	m_game.spawnPlayerAgents()

	emit_signal("finished")


func matchModuleToSavedGame( filePath : String ):
	if m_module and not m_module.moduleMatches( filePath ):
		m_game.setCurrentModule( null )

	if not m_game.m_module:
		var module = SavingModuleGd.createFromSaveFile( filePath )
		if not module:
			UtilityGd.log("could not load game from file %s" % filePath )
			return
		else:
			m_game.setCurrentModule( module )
	else:
		m_module.loadFromFile( filePath )


