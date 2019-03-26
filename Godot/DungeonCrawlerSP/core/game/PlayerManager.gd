extends Node


const PlayerName = 'Player1'

var _playerUnits := SetWrapper.new()         setget deleted, getUnits
onready var _game : Node = get_parent()


func deleted(_a):
	assert(false)


func _ready():
	_playerUnits.connect( "changed", self, "_onUnitsChanged" )
	_game.connect("currentLevelChanged", self, "_onCurrentLevelChanged" )


func setPlayerUnits( playerUnits : Array ):
	var unitRaiiArray := []
	for unit in playerUnits:
		assert( unit is UnitBase )
		unitRaiiArray.append( NodeRAII.new( unit ) )

	_playerUnits.reset( unitRaiiArray )


func addPlayerUnits( playerUnits : Array ):
	var unitRaiiArray := []
	for unit in playerUnits:
		assert( unit is UnitBase )
		unitRaiiArray.append( NodeRAII.new( unit ) )

	_playerUnits.add( unitRaiiArray )


func removePlayerUnits( playerUnits : Array ):
	var unitRaiiArray := []
	for unit in playerUnits:
		assert( unit is UnitBase )
		unitRaiiArray.append( NodeRAII.new( unit ) )

	_playerUnits.remove( unitRaiiArray )


func getPlayerUnitNodes():
	var nodes = []
	for playerUnit in _playerUnits.container():
		assert( playerUnit.getNode() is UnitBase )
		nodes.append( playerUnit.getNode() )
	return nodes


func getAgent( agentName : String ):
	return get_node( agentName ) if has_node( agentName ) else null


func getUnits():
	return _playerUnits.container()


func _onUnitsChanged( playerUnits : Array ):
	if is_instance_valid( _game._currentLevel ):
		_connectUnitsToLevel( playerUnits, _game._currentLevel )

	var agent : AgentBase = get_node( PlayerName )

	for unit in playerUnits:
		assert( unit is NodeRAII )
		if not unit in agent.getUnits():
			agent.addUnit( unit.getNode() )


func _onCurrentLevelChanged( level : LevelBase ):
	if is_instance_valid( level ):
		_connectUnitsToLevel( _playerUnits.container(), level )


func _connectUnitsToLevel( playerUnits : Array, level : LevelBase ):
	for playerUnit in playerUnits:
		assert( playerUnit is NodeRAII )
		var unitNode : UnitBase = playerUnit.getNode()

		if unitNode.is_connected( "tree_entered", level, "addUnitToFogVision" ):
			continue

		unitNode.connect( "tree_entered", level, "addUnitToFogVision",      [unitNode] )
		unitNode.connect( "tree_exiting", level, "removeUnitFromFogVision", [unitNode] )

		if unitNode.is_inside_tree():
			level.addUnitToFogVision( unitNode )



