extends Reference

const UnitMax = 4
const Units = [
	"Dwarf",
	"Gnome",
	"Wizard"
	]

const StartingLevelName = "Level1"

const LevelNames = [
	"Level1",
	"Level2",
	]

const DefaultLevelEntrances = {
	"Level1" : "Entrance",
	"Level2" : "Entrance",
	}

const LevelConnections = {
	["Level1", "ToLevel2"] : ["Level2", "Entrance"],
	["Level2", "ToLevel1"] : ["Level1", "ToLevel2"]
}
