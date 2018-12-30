extends Node

const PlayerAgentGd          = preload("res://agents/PlayerAgent.gd")
const GlobalGd               = preload("res://GlobalNames.gd")
const PlayerUnitGd           = preload("./PlayerUnit.gd")
const SetWrapperGd           = preload("res://addons/TypeWrappers/SetWrapper.gd")

const NoOwnerId = 0

var m_playerIds : SetWrapperGd = SetWrapperGd.new()   setget deleted, getPlayerIds
var m_playerUnits : Array = []         setget deleted # _setPlayerUnits
var m_rpcTargets = []                  setget deleted
var m_agents = []                      setget deleted


func deleted(_a):
	assert(false)


func _enter_tree():
	m_rpcTargets = get_parent().m_rpcTargets
	Network.connect( "clientListChanged", self, "adjustPlayersToClients" )


func setPlayerIds( ids : Array ):
	m_playerIds.reset( ids )


func adjustPlayersToClients( clients : Dictionary ):
	var playersToRemove : Array = []
	for playerId in m_playerIds.m_array:
		if not clients.has( playerId ):
			playersToRemove.append( playerId )

	m_playerIds.remove( playersToRemove )


func getPlayerIds():
	return m_playerIds.m_array.duplicate()
