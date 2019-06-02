extends Node

const PlayerAgentGd          = preload("res://core/agent/PlayerAgent.gd")

onready var playerAgent : PlayerAgentGd = $"PlayerAgent"


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


func getPlayerUnits():
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


func _updatePlayerAgentProcessing():
	playerAgent.setProcessing( !Console._consoleBox.visible )
