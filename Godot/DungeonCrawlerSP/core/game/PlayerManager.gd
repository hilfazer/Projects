extends Node

const PlayerUnitGd           = preload("./PlayerUnit.gd")

var m_playerUnits : Array = []         setget  setPlayerUnits




func setPlayerUnits( units : Array ):
	for unit in units:
		assert( unit is PlayerUnitGd )
	m_playerUnits = []
	m_playerUnits = units


func getPlayerUnitNodes():
	var nodes = []
	for playerUnit in m_playerUnits:
		nodes.append( playerUnit.m_unitNode_ )
	return nodes



