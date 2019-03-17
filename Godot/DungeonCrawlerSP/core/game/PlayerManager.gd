extends Node

const PlayerAgentGd          = preload("res://core/PlayerAgent.gd")
const UnitBaseGd             = preload("res://core/UnitBase.gd")

var _playerUnits : Array = []          setget  setPlayerUnits


func setPlayerUnits( units : Array ):
	for unit in units:
		assert( unit.getNode() is UnitBaseGd )
		unit.getNode().add_child( PlayerAgentGd.new() )

	_playerUnits = []
	_playerUnits = units


func getPlayerUnitNodes():
	var nodes = []
	for playerUnit in _playerUnits:
		nodes.append( playerUnit.getNode() )
	return nodes



