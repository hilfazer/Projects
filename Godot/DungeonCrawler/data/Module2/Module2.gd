extends "res://engine/ModuleData.gd"

const ItemDatabaseGd = preload("./items/Module2ItemDatabase.gd")
var itemDatabase = ItemDatabaseGd.new()

const UnitMax = 5
const Units = ["Elf", "Knight"]

const StartingLevelName = "Level1"

const LevelNames = [
	"Level1",
	"Level2",
	]

const DefaultLevelEntrances = {
	"Level1" : "Start",
	}

const LevelConnections = {
	["Level1", "ToLevel2"] : ["Level2", "ToLevel1"],
	["Level2", "ToLevel1"] : ["Level1", "ToLevel2"],
}
