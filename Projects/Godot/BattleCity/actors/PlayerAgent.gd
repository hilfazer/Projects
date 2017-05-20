extends "res://actors/Agent.gd"

const TankGd = preload("res://units/tank.gd")

var m_moveUpAction 
var m_moveDownAction 
var m_moveLeftAction 
var m_moveRightAction 
var m_shootAction 

func setActions( actions ):
	assert( actions.size() >= 5 )
	m_moveUpAction = actions[0]
	m_moveDownAction  = actions[1]
	m_moveLeftAction  = actions[2]
	m_moveRightAction  = actions[3]
	m_shootAction  = actions[4]


func processMovement(delta):
	var direction = TankGd.Direction.NONE
	
	if (Input.is_action_pressed(m_moveUpAction)):
		direction = TankGd.Direction.UP
	elif (Input.is_action_pressed(m_moveDownAction)):
		direction = TankGd.Direction.DOWN
	elif (Input.is_action_pressed(m_moveLeftAction)):
		direction = TankGd.Direction.LEFT
	elif (Input.is_action_pressed(m_moveRightAction)):
		direction = TankGd.Direction.RIGHT
	
	if direction != m_tank.m_direction:
		m_tank.setDirection( direction )
	
	
func processFiring(delta):
	if (Input.is_action_pressed(m_shootAction)):
		m_tank.fireCannon()