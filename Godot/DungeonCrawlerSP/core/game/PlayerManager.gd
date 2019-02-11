extends Node

const PlayerUnitGd           = preload("./PlayerUnit.gd")
const PlayerAgentGd          = preload("res://core/PlayerAgent.gd")

var m_playerUnits : Array = []         setget  setPlayerUnits




func setPlayerUnits( units : Array ):
	for unit in units:
		assert( unit is PlayerUnitGd )
		unit.m_unitNode_.add_child( PlayerAgentGd.new() )

	m_playerUnits = []
	m_playerUnits = units


func getPlayerUnitNodes():
	var nodes = []
	for playerUnit in m_playerUnits:
		nodes.append( playerUnit.m_unitNode_ )
	return nodes



