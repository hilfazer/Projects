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


#func registerPlayerWithGameScene( playerId ):
#	if not playerId in m_playersWithGameScene:
#		m_playersWithGameScene.append( playerId )
#		m_playersWithGameScene.sort()
#		var playersIds = [m_game.get_tree().get_network_unique_id()] + m_game.m_rpcTargets
#		playersIds.sort()
#		if m_playersWithGameScene == playersIds:
#			call_deferred( "prepare" )


func prepare():
	assert( is_inside_tree() )
	assert( is_network_master() )
	assert( m_game.m_currentLevel == null )

	var levelFilename = m_module.getStartingLevelFilenameAndEntrance()[0]
	var levelEntrance = m_module.getStartingLevelFilenameAndEntrance()[1]

	m_game.createPlayerUnits( m_playerUnitsCreationData )
	m_game.loadLevel( levelFilename, m_game.get_path() )
	m_game.m_levelLoader.insertPlayerUnits( \
		m_game.getPlayerUnits(), m_game.m_currentLevel, levelEntrance )

	m_game.spawnPlayerAgents()

	emit_signal("finished")


#sync func finalize():
#	if is_network_master():
#		readyToStart( get_tree().get_network_unique_id() )
#
#
#remote func readyToStart(id):
#	assert( Network.isServer() )
#	assert(not id in m_playersReady)
#
#	if (id in Network.m_clients):
#		m_playersReady.append(id)
#
#	if (m_playersReady.size() < Network.m_clients.size()):
#		return
#
#	emit_signal("finished")
