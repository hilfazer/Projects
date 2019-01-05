extends Reference

const UnitMax = 4
const Units = [
	"Dwarf",
	"Gnome",
	"Wizard"
	]

const StartingLevelName = "Level1"
const StartingLevelEntrance = "Entrance"

const LevelNamesToFilenames = {
	"Level1" : "Level1.tscn",
	"Level2" : "Level2.tscn"
	}

const LevelConnections = {
	["Level1", "ToLevel2"] : ["Level2", "Entrance"],
	["Level2", "ToLevel1"] : ["Level1", "ToLevel2"]
}
