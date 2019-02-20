extends Node

const PlayerAgentGd          = preload("res://core/PlayerAgent.gd")
const UnitBaseGd             = preload("res://core/UnitBase.gd")

var m_playerUnits : Array = []         setget  setPlayerUnits


func setPlayerUnits( units : Array ):
	for unit in units:
		assert( unit.getNode() is UnitBaseGd )
		unit.getNode().add_child( PlayerAgentGd.new() )

	m_playerUnits = []
	m_playerUnits = units


func getPlayerUnitNodes():
	var nodes = []
	for playerUnit in m_playerUnits:
		nodes.append( playerUnit.getNode() )
	return nodes



