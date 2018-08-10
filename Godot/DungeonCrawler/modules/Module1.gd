extends "res://modules/Module.gd"

const UnitMax = 4
const Units = ["res://units/Dwarf.tscn", "res://units/Gnome.tscn", "res://units/Wizard.tscn"]

const LevelNamesToFilenames = {
	"Level1" : "res://levels/Level1.tscn",
	"Level2" : "res://levels/Level2.tscn"
	}

const LevelConnections = {
	["Level1", "ToLevel2"] : ["Level2", "Entrance"],
	["Level2", "ToLevel1"] : ["Level1", "ToLevel2"]
}
