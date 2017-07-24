extends Node2D

const PowerupFactoryScn = preload("res://powerups/PowerupFactory.tscn")
const TankGd = preload("res://units/Tank.gd")

const IdxToColor = { 
	1 : TankGd.ColorOffset.SILVER,
	2 : TankGd.ColorOffset.GOLD, 
	3 : TankGd.ColorOffset.GREEN,
	4 : TankGd.ColorOffset.PURPLE
}

export (String, "", "Helmet", "Star") var m_powerupName = ""
var m_tank                setget deleted, deleted
var m_originalTankColor   setget deleted, deleted


func deleted():
	assert(false)


func _ready():
	m_tank = get_parent()
	get_node("AnimationPlayer").play("changeTankColor")


func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		var powerupFactory = PowerupFactoryScn.instance()
		var powerup = powerupFactory.makePowerup(m_powerupName) \
			if m_powerupName != "" \
			else powerupFactory.makeRandomPowerup()
		m_tank.m_stage.get_ref().placePowerup( powerup )
		powerupFactory.free()


func setTankOriginalColor():
	if m_tank.m_colorFrame == TankGd.ColorOffset.PURPLE:
		m_tank.setColor( m_originalTankColor )


func setPurpleColor():
	m_originalTankColor = m_tank.m_colorFrame
#	assert( m_originalTankColor != TankGd.ColorOffset.PURPLE )
	m_tank.setColor( TankGd.ColorOffset.PURPLE )
