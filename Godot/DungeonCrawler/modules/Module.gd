# abstract class for new or saved module
extends Node


func getUnitsForCreation():
	assert(false)


func getExistingPlayerUnits():
	return []       # default for new modules


func getStartingLevelFilenameAndEntrance():
	assert(false)
	
	
func getLevelFilename( levelName ):
	assert(false)
	
	
func getTargetLevelFilenameAndEntrance( sourceLevelName, entrance ):
	assert(false)


func getPlayerUnitMax():
	assert(false)
