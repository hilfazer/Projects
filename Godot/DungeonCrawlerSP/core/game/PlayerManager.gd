extends Node

var _playerUnits := SetWrapper.new()         setget deleted, getUnits


func deleted(_a):
	assert(false)


func setPlayerUnits( playerUnits : Array ):
	for unit in playerUnits:
		assert( unit is NodeRAII )
		assert( unit.getNode() is UnitBase )

	_playerUnits.reset( playerUnits )


func addPlayerUnits( playerUnits : Array ):
	for unit in playerUnits:
		assert( unit is NodeRAII )
		assert( unit.getNode() is UnitBase )

	_playerUnits.add( playerUnits )


func getPlayerUnitNodes():
	var nodes = []
	for playerUnit in _playerUnits.container():
		assert( playerUnit.getNode() is UnitBase )
		nodes.append( playerUnit.getNode() )
	return nodes


func addAgent( agent__ : AgentBase ):
	add_child( agent__ )
	return agent__.name


func eraseAgent( agentName : String ):
	pass
	if has_node( agentName ):
		Utility.setFreeing( get_node( agentName ) )
	else:
		Debug.warn( self, "No agent named %s." % [agentName] )


func getUnits():
	return _playerUnits.container()
