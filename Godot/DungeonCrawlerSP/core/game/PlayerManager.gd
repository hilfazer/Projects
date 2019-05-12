extends Node

const PlayerAgentGd          = preload("res://core/agent/PlayerAgent.gd")

onready var playerAgent : PlayerAgentGd = $"PlayerAgent"
var _currentLevel : LevelBase          setget deleted


func deleted(_a):
	assert(false)


func _ready():
	playerAgent.connect( "unitsChanged", self, "_onUnitsChanged" )
	Console._consoleBox.connect( "visibility_changed", self, "_updatePlayerAgentProcessing" )


func setPlayerUnits( playerUnits : Array ):
	for unit in playerUnits:
		assert( unit is UnitBase )

	var unitsToRemove := []
	for unit in playerAgent.getUnits():
		if not unit in playerUnits:
			unitsToRemove.append( unit )

	Utility.freeIfNotInTree( unitsToRemove )

	for unit in playerUnits:
		playerAgent.addUnit( unit )


func addPlayerUnits( playerUnits : Array ):
	for unit in playerUnits:
		assert( unit is UnitBase )
		playerAgent.addUnit( unit )


func removePlayerUnits( playerUnits : Array ):
	for unit in playerUnits:
		assert( unit is UnitBase )
		playerAgent.removeUnit( unit )

	Utility.freeIfNotInTree( playerUnits )


# TODO: change name
func getPlayerUnitNodes():
	return playerAgent.getUnits()


func unparentUnits():
	for unit in playerAgent.getUnits():
		assert( unit is UnitBase )
		unit.get_parent().remove_child( unit )


func _onUnitsChanged( changedUnits : Array ):
	var unitsToRemove := []
	var unitsToAdd    := []

	for unit in playerAgent.getUnits():
		if not unit in changedUnits:
			unitsToRemove.append( unit )

	for unit in changedUnits:
		assert( unit is UnitBase )
		if not unit in playerAgent.getUnits():
			unitsToAdd.append( unit )

	for unit in unitsToRemove:
		playerAgent.removeUnit( unit )

	for unit in unitsToAdd:
		playerAgent.addUnit( unit )

	if is_instance_valid( _currentLevel ):
		_connectUnitsToLevel( playerAgent.getUnits(), _currentLevel )


func _onCurrentLevelChanged( level : LevelBase ):
	_currentLevel = level
	if is_instance_valid( level ):
		_connectUnitsToLevel( playerAgent.getUnits(), level )


func _connectUnitsToLevel( playerUnits : Array, level : LevelBase ):
	for playerUnit in playerUnits:
		assert( playerUnit is UnitBase )
		if playerUnit.is_connected( "tree_entered", level, "addUnitToFogVision" ):
			continue

		playerUnit.connect( "tree_entered", level, "addUnitToFogVision",      [playerUnit] )
		playerUnit.connect( "tree_exiting", level, "removeUnitFromFogVision", [playerUnit] )

		if playerUnit.is_inside_tree():
			level.addUnitToFogVision( playerUnit )

	for unit in level.getFogVisionUnits():
		if not unit in playerUnits:
			level.removeUnitFromFogVision( unit )
			unit.disconnect( "tree_entered", level, "addUnitToFogVision" )
			unit.disconnect( "tree_exiting", level, "removeUnitFromFogVision" )


func _updatePlayerAgentProcessing():
	playerAgent.setProcessing( !Console._consoleBox.visible )
