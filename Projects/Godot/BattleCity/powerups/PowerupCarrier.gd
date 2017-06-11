extends Node2D

const PowerupFactoryScn = preload("res://powerups/PowerupFactory.tscn")
const TankGd = preload("res://units/Tank.gd")

const IdxToColor = { 1 : TankGd.ColorOffset.SILVER, 2 : TankGd.ColorOffset.GOLD, \
	3 : TankGd.ColorOffset.GREEN, 4 : TankGd.ColorOffset.PURPLE }
	
var m_tank
export (String, "", "Helmet", "Star") var m_powerupName = ""


func _ready():
	m_tank = get_parent()
	get_node("AnimationPlayer").play("changeTankColor")


func _exit_tree():
	var powerupFactory = PowerupFactoryScn.instance()
	var powerup = powerupFactory.makePowerup(m_powerupName) \
		if m_powerupName != "" \
		else powerupFactory.makeRandomPowerup()
	m_tank.m_stage.get_ref().placePowerup( powerup )
	powerupFactory.free()


func changeTankColor(colorIdx):
	m_tank.setColor( IdxToColor[colorIdx] )
	
