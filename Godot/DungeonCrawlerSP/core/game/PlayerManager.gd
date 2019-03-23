extends Node

const UnitBaseGd             = preload("res://core/UnitBase.gd")

var _playerUnits := SetWrapper.new()         setget deleted, getUnits


func deleted(_a):
	assert(false)


func setPlayerUnits( playerUnits : Array ):
	for unit in playerUnits:
		assert( unit is NodeRAII )
		assert( unit.getNode() is UnitBaseGd )

	_playerUnits.reset( playerUnits )


func addPlayerUnits( playerUnits : Array ):
	for unit in playerUnits:
		assert( unit is NodeRAII )
		assert( unit.getNode() is UnitBaseGd )

	_playerUnits.add( playerUnits )


func getPlayerUnitNodes():
	var nodes = []
	for playerUnit in _playerUnits.container():
		assert( playerUnit.getNode() is UnitBaseGd )
		nodes.append( playerUnit.getNode() )
	return nodes


func addAgent( agent_ : AgentBase ):
	add_child( agent_ )
	return agent_.name


func eraseAgent( agentName : String ):
	pass
	if has_node( agentName ):
		Utility.setFreeing( get_node( agentName ) )
	else:
		Debug.warn( self, "No agent named %s." % [agentName] )


func getUnits():
	return _playerUnits.container()
