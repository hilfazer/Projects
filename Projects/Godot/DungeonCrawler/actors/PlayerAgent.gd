extends "res://actors/Agent.gd"

const UnitGd = preload("res://units/unit.gd")

const PlayersActions = [
	["move_up", "move_down", "move_left", "move_right"]
]

var m_moveUpAction    
var m_moveDownAction  
var m_moveLeftAction  
var m_moveRightAction


func deleted():
	assert(false)
	
	
func copyState(node):
	.copyState(node)
	node.m_moveUpAction = m_moveUpAction
	node.m_moveDownAction = m_moveDownAction
	node.m_moveLeftAction = m_moveLeftAction
	node.m_moveRightAction = m_moveRightAction


func setActions( actions ):
	assert( actions.size() >= PlayersActions.size() )
	m_moveUpAction = actions[0]
	m_moveDownAction  = actions[1]
	m_moveLeftAction  = actions[2]
	m_moveRightAction  = actions[3]


func processMovement(delta):
	var movement = Vector2(0, 0)
	if (Input.is_action_pressed(m_moveDownAction)):
		movement.y += 1
	if (Input.is_action_pressed(m_moveUpAction)):
		movement.y -= 1
	if (Input.is_action_pressed(m_moveLeftAction)):
		movement.x -= 1
	if (Input.is_action_pressed(m_moveRightAction)):
		movement.x += 1
		
	if ( get_tree().get_network_unique_id() == 1 ):
		m_unit.setMovement(movement)
	else:
		m_unit.rpc_id(1, "setMovement", movement)


func assignToUnit( unit ):
	.assignToUnit( unit )
	
