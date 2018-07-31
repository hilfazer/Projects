extends "res://modules/Module.gd"


const Units = ["res://units/Dwarf.tscn", "res://units/Gnome.tscn", "res://units/Wizard.tscn"]

const Levels = [
	"res://levels/Level1.tscn",
	"res://levels/Level2.tscn"
]

const LevelConnections = {
	["Level1", "ToLevel2"] : ["res://levels/Level2.tscn", "Entrance"],
	["Level2", "ToLevel1"] : ["res://levels/Level1.tscn", "ToLevel2"]
}

var m_nextLevelIndex = 0


func getUnitsForCreation():
	return Units


func getStartingLevel():
	m_nextLevelIndex = 1
	return Levels[0]
	
	
func getLevelConnections():
	return LevelConnections


func getPlayerUnitMax():
	return 4
