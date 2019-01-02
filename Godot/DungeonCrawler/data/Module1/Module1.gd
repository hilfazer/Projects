extends Reference

const UnitMax = 4
const Units = [
	"res://data/common/units/Dwarf.tscn",
	"res://data/common/units/Gnome.tscn",
	"res://data/common/units/Wizard.tscn"
	]

const StartingLevelName = "Level1"
const StartingLevelEntrance = "Entrance"

const LevelNamesToFilenames = {
	"Level1" : "res://levels/Level1.tscn",
	"Level2" : "res://levels/Level2.tscn"
	}

const LevelConnections = {
	["Level1", "ToLevel2"] : ["Level2", "Entrance"],
	["Level2", "ToLevel1"] : ["Level1", "ToLevel2"]
}
