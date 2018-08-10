# abstract class for new or saved module
extends Node

# override those constants in subclass
const UnitMax = null
const Units = []
const LevelNamesToFilenames = {}
const LevelConnections = {}


func getPlayerUnitMax():
	return UnitMax


func getUnitsForCreation():
	return Units


func getStartingLevelFilenameAndEntrance():
	return [ LevelNamesToFilenames["Level1"], "Entrance" ]


func getLevelFilename( levelName ):
	assert( LevelNamesToFilenames.has(levelName) )
	return LevelNamesToFilenames[levelName]


func getTargetLevelFilenameAndEntrance( sourceLevelName, entrance ):
	assert( LevelNamesToFilenames.has(sourceLevelName) )
	if not LevelConnections.has( [sourceLevelName, entrance] ):
		return null

	var name_entrance = LevelConnections[[sourceLevelName, entrance]]

	return [ getLevelFilename( name_entrance[0] ), name_entrance[1] ]


func getExistingPlayerUnits():
	return []       # default for new modules
