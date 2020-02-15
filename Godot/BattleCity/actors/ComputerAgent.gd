extends "res://actors/Agent.gd"

const TankGd = preload("res://units/tank.gd")

const MovementDecisionFrequency = 1.5

var m_timeSinceMovementDecision = 0.0
var m_direction = TankGd.Direction.DOWN
var m_timeSinceLastShot = 0.5
var m_shootingFrequency = 2.0


func processMovement(delta):
	m_timeSinceMovementDecision += delta
	if ( m_timeSinceMovementDecision > MovementDecisionFrequency ):
		m_direction = chooseDirection( m_direction )
		m_timeSinceMovementDecision = 0.0
	m_tank.setDirection( m_direction )


func processFiring(delta):
	m_timeSinceLastShot += delta

	if ( m_timeSinceLastShot > m_shootingFrequency ):
		m_tank.fireCannon()
		m_timeSinceLastShot = 0.0


func readDefinition(definition):
	m_shootingFrequency = definition.shootFrequency


func chooseDirection( direction ):
	var number = randi() % 8

	if number == 0:
		return TankGd.Direction.UP
	elif number == 1:
		return TankGd.Direction.LEFT
	elif number == 2:
		return TankGd.Direction.RIGHT
	elif number == 3:
		return TankGd.Direction.DOWN
	else:
		return direction
