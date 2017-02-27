extends "res://units/Agent.gd"

const TankGd = preload("res://units/tank.gd")

var m_motion = TankGd.MOTION.DOWN
var m_timeSinceLastShot = 0.5
var m_shootingFrequency = 2.0


func processMovement(delta):
	m_tank.setMotion( m_motion )


func processFiring(delta):
	m_timeSinceLastShot += delta

	if ( m_timeSinceLastShot > m_shootingFrequency ):
		m_tank.fireCannon()
		m_timeSinceLastShot = 0.0


func readDefinition(definition):
	m_shootingFrequency = definition.shootFrequency