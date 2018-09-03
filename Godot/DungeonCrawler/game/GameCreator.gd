extends Node


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

