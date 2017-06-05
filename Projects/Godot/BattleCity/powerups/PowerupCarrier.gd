extends Node2D

const PowerupFactoryScn = preload("res://powerups/PowerupFactory.tscn")

var m_tank
export (String, "", "Helmet", "Star") var m_powerupName


func _ready():
	m_tank = get_parent()


func _exit_tree():
	var powerupFactory = PowerupFactoryScn.instance()
	m_tank.m_stage.get_ref().placePowerup( powerupFactory.makePowerup(m_powerupName) )
	powerupFactory.free()