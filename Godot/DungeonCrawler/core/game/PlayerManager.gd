extends Node

const PlayerAgentGd          = preload("res://core/PlayerAgent.gd")
const GlobalGd               = preload("res://core/GlobalNames.gd")
const PlayerUnitGd           = preload("./PlayerUnit.gd")
const SetWrapperGd           = preload("res://addons/TypeWrappers/SetWrapper.gd")

const NoOwnerId = 0

var m_playerIds : SetWrapperGd = SetWrapperGd.new()   setget deleted, getPlayerIds
var m_playerUnits : Array = []         setget deleted # _setPlayerUnits
var m_agents = []                      setget deleted


func deleted(_a):
	assert(false)


func _enter_tree():
	Network.connect( "clientListChanged", self, "_adjustToClients" )


func setPlayerIds( ids : Array ):
	m_playerIds.reset( ids )


func _adjustToClients( clients : Dictionary ):
	var playersToRemove : Array = []
	for playerId in m_playerIds.m_array:
		if not clients.has( playerId ):
			playersToRemove.append( playerId )

	m_playerIds.remove( playersToRemove )


func getPlayerIds():
	return m_playerIds.m_array.duplicate()


func getPlayerUnitNodes():
	return m_playerUnits
