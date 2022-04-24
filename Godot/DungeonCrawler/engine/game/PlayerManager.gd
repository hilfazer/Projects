extends Node

#TODO remove PlayerManager

const PlayerAgentGd          = preload("res://engine/agent/PlayerAgent.gd")

onready var playerAgent : PlayerAgentGd = $"PlayerAgent"


func deleted(_a):
	assert(false)


func setPlayerUnits( playerUnits : Array ):
	for unit in playerUnits:
		assert( unit is UnitBase )

	var unitsToRemove := []
	for unit in playerAgent.getUnits():
		if not unit in playerUnits:
			unitsToRemove.append( unit )

	Utility.freeIfNotInTree( unitsToRemove )

	addPlayerUnits( playerUnits )


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


func _updatePlayerAgentProcessing():
	playerAgent.setProcessing( !Console._consoleBox.visible )
