extends "res://modules/Module.gd"

const UnitMax = 4
const Units = ["res://units/Dwarf.tscn", "res://units/Gnome.tscn", "res://units/Wizard.tscn"]

const LevelNamesToFilenames = {
	"Level1" : "res://levels/Level1.tscn",
	"Level2" : "res://levels/Level2.tscn"
	}

const LevelConnections = {
	["Level1", "ToLevel2"] : ["Level2", "Entrance"],
	["Level2", "ToLevel1"] : ["Level1", "ToLevel2"]
}


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
