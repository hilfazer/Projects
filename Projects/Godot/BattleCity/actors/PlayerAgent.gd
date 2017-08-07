extends "res://actors/Agent.gd"

const TankGd = preload("res://units/tank.gd")
const PowerupGd = preload("res://powerups/powerup.gd")

const PlayersActions = [
	["player1_move_up", "player1_move_down", "player1_move_left", "player1_move_right", "player1_shoot"],
	["player2_move_up", "player2_move_down", "player2_move_left", "player2_move_right", "player2_shoot"]
]

var m_moveUpAction    
var m_moveDownAction  
var m_moveLeftAction  
var m_moveRightAction
var m_shootAction 
var m_playerId        setget setPlayerId


func deleted():
	assert(false)
	
	
func copyState(node):
	.copyState(node)
	node.m_moveUpAction = m_moveUpAction
	node.m_moveDownAction = m_moveDownAction
	node.m_moveLeftAction = m_moveLeftAction
	node.m_moveRightAction = m_moveRightAction
	node.m_shootAction = m_shootAction
	node.m_playerId = m_playerId


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


func assignToTank( tank ):
	.assignToTank( tank )
	tank.get_node("Area2D").connect("area_enter", self, "tankHitArea")


func tankHitArea(area):
	if area.get_parent().is_in_group("Powerups"):
		area.get_parent().pickup(m_tank)
		Game.awardPoints(m_playerId, PowerupGd.PointReward)
	
	
func setPlayerId(playerId):
	m_playerId = playerId
