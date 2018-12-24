extends Node

const PlayerAgentGd          = preload("res://agents/PlayerAgent.gd")
const GlobalGd               = preload("res://GlobalNames.gd")
const PlayerUnitGd           = preload("./PlayerUnit.gd")

const NoOwnerId = 0

var m_playerUnits : Array = []         setget deleted # _setPlayerUnits
var m_rpcTargets = []                  setget deleted
var m_agents = []                      setget deleted


func deleted(_a):
	assert(false)


signal agentReady( agentNodeName )


func _enter_tree():
	m_rpcTargets = get_parent().m_rpcTargets
#	_registerCommands()

