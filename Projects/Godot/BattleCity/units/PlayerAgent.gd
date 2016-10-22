extends Node

var m_tank = null
var m_moveUpAction 
var m_moveDownAction 
var m_moveLeftAction 
var m_moveRightAction 
var m_shootAction 
var m_lastTankMotion
var m_lastXDirectionRequested
var m_lastYDirectionRequested

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
	m_lastTankMotion = m_tank.getMotion()
	m_lastXDirectionRequested = m_tank.MOTION.NONE
	m_lastYDirectionRequested = m_tank.MOTION.NONE

func _ready():
	set_process( true )
	
func _process(delta):
	processMovement()
	processFiring()
	
	
func processMovement():
	var verticalMotionRequest = m_tank.MOTION.NONE
	
	if (Input.is_action_pressed(m_moveUpAction) and Input.is_action_pressed(m_moveDownAction)):
		pass
	elif (Input.is_action_pressed(m_moveUpAction)):
		verticalMotionRequest = m_tank.MOTION.UP
	elif (Input.is_action_pressed(m_moveDownAction)):
		verticalMotionRequest = m_tank.MOTION.DOWN
	
	var horizontalMotionRequest = m_tank.MOTION.NONE

	if (Input.is_action_pressed(m_moveLeftAction) and Input.is_action_pressed(m_moveRightAction)):
		pass
	elif (Input.is_action_pressed(m_moveLeftAction)):
		horizontalMotionRequest = m_tank.MOTION.LEFT
	elif (Input.is_action_pressed(m_moveRightAction)):
		horizontalMotionRequest = m_tank.MOTION.RIGHT
	
	var motion = m_tank.MOTION.NONE
	var motionAlt = m_tank.MOTION.NONE
	
	if (horizontalMotionRequest == m_tank.MOTION.NONE) and (verticalMotionRequest != m_tank.MOTION.NONE):
		motion = verticalMotionRequest
	elif (horizontalMotionRequest != m_tank.MOTION.NONE) and (verticalMotionRequest == m_tank.MOTION.NONE):
		motion = horizontalMotionRequest
	elif m_lastXDirectionRequested == m_tank.MOTION.NONE and m_lastYDirectionRequested != m_tank.MOTION.NONE:
		motion = horizontalMotionRequest
		motionAlt = verticalMotionRequest
	elif m_lastXDirectionRequested != m_tank.MOTION.NONE and m_lastYDirectionRequested == m_tank.MOTION.NONE:
		motion = verticalMotionRequest
		motionAlt = horizontalMotionRequest
	else: 
		motion = m_tank.getMotion()
	
	if motion != m_lastTankMotion:
		m_tank.setMotion( motion, motionAlt )
		m_lastTankMotion = m_tank.getMotion()
		
	m_lastYDirectionRequested = verticalMotionRequest
	m_lastXDirectionRequested = horizontalMotionRequest
	
	
func processFiring():
	if (Input.is_action_pressed(m_shootAction)):
		m_tank.fireCannon()
		
		
		
		
		