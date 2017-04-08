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
	var motion = TankGd.MOTION.NONE
	
	if (Input.is_action_pressed(m_moveUpAction)):
		motion = TankGd.MOTION.UP
	elif (Input.is_action_pressed(m_moveDownAction)):
		motion = TankGd.MOTION.DOWN
	elif (Input.is_action_pressed(m_moveLeftAction)):
		motion = TankGd.MOTION.LEFT
	elif (Input.is_action_pressed(m_moveRightAction)):
		motion = TankGd.MOTION.RIGHT
	
	if motion != m_lastMotion:
		m_tank.setMotion( motion )
		m_lastMotion = m_tank.getMotion()
	
	
func processFiring(delta):
	if (Input.is_action_pressed(m_shootAction)):
		m_tank.fireCannon()
		
		
		
		
		