extends Reference

const UnitMax = 5
const Units = ["Dwarf.tscn", "Gnome.tscn", "Wizard.tscn"]

const StartingLevelName = "Level2"
const StartingLevelEntrance = "Entrance"

const LevelNamesToFilenames = {
	"Level1" : "Level1.tscn",
	"Level2" : "Level2.tscn"
	}

const LevelConnections = {
	["Level1", "ToLevel2"] : ["Level2", "Entrance"],
	["Level2", "ToLevel1"] : ["Level1", "ToLevel2"]
}
