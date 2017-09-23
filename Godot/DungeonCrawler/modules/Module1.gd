extends "res://modules/Module.gd"


const StartingMap = "res://levels/World.tscn"
const Units = ["res://units/Dwarf.tscn", "res://units/Gnome.tscn", "res://units/Wizard.tscn"]


func getUnitsForCreation():
	return Units


func getStartingMap():
	return StartingMap


func getPlayerUnitMax():
	return 4
