extends Node

var m_tank = null
var m_moveUpAction 
var m_moveDownAction 
var m_moveLeftAction 
var m_moveRightAction 
var m_shootAction 
var m_lastMotion

func setActions( actions ):
	assert( actions.size() >= 5 )
	m_moveUpAction = actions[0]
	m_moveDownAction  = actions[1]
	m_moveLeftAction  = actions[2]
	m_moveRightAction  = actions[3]
	m_shootAction  = actions[4]
	
func assignToTank( tank ):
	m_tank = tank
	m_tank.add_child( self )
	m_lastMotion = m_tank.getMotion()

func _ready():
	set_process( true )
	
func _process(delta):
	processMovement()
	processFiring()
	
	
func processMovement():
	var motion = Vector2()
	
	if (Input.is_action_pressed(m_moveUpAction)):
		motion = m_tank.MOTION.UP
	elif (Input.is_action_pressed(m_moveDownAction)):
		motion = m_tank.MOTION.DOWN
	elif (Input.is_action_pressed(m_moveLeftAction)):
		motion = m_tank.MOTION.LEFT
	elif (Input.is_action_pressed(m_moveRightAction)):
		motion = m_tank.MOTION.RIGHT
	
	if motion != m_lastMotion:
		m_tank.setMotion( motion )
		m_lastMotion = m_tank.getMotion()
	
	
func processFiring():
	if (Input.is_action_pressed(m_shootAction)):
		m_tank.fireCannon()
		
		
		
		
		