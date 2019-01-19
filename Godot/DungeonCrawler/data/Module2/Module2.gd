extends Reference

const UnitMax = 5
const Units = ["Dwarf", "Gnome", "Wizard"]

const StartingLevelName = "Level1"
const StartingLevelEntrance = "Entrance"

const LevelNames = [
	"Level1",
	"Level2",
	]

const LevelConnections = {
	["Level1", "ToLevel2"] : ["Level2", "Entrance"],
	["Level2", "ToLevel1"] : ["Level1", "ToLevel2"]
}
