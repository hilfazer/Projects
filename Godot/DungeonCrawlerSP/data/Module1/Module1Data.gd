extends Reference

const Module1ItemDatabaseGd = preload("res://data/Module1/items/Module1ItemDatabase.gd")

const UnitMax = 4
const Units = [
	"Dwarf",
	"Knight",
	]

const StartingLevelName = "Level1"

const LevelNames = [
	"Level1",
	"Level2",
	]

const DefaultLevelEntrances = {
	"Level1" : "Start",
	"Level2" : "ToLevel1",
	}

const LevelConnections = {
	["Level1", "ToLevel2"] : ["Level2", "ToLevel1"],
	["Level2", "ToLevel1"] : ["Level1", "ToLevel2"],
}
