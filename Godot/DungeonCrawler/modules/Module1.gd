extends "res://modules/Module.gd"


const Units = ["res://units/Dwarf.tscn", "res://units/Gnome.tscn", "res://units/Wizard.tscn"]

const Levels = [
	"res://levels/Level1.tscn",
	"res://levels/Level2.tscn"
]
var m_nextLevelIndex = 0


func getUnitsForCreation():
	return Units


func getStartingLevel():
	m_nextLevelIndex = 1
	return Levels[0]


func getNextLevel():
	var levelIndex = m_nextLevelIndex
	m_nextLevelIndex += 1
	return Levels[levelIndex] if levelIndex < Levels.size() else null


func getPlayerUnitMax():
	return 4
