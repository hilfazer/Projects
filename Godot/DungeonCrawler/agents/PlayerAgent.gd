extends "Agent.gd"

const UnitGd                 = preload("res://units/Unit.gd")

const PlayersActions = [
	["move_up", "move_down", "move_left", "move_right"]
]

var m_moveUpAction    
var m_moveDownAction  
var m_moveLeftAction  
var m_moveRightAction

var m_movement = Vector2(0, 0)
slave var m_movementSentToServer

var m_units = []         setget deleted


func deleted(a):
	assert(false)


func _init():
	# set default actions
	setActions( PlayersActions[0] )


func _unhandled_input(event):
	if not is_network_master():
		return
	
	if (event.is_action_pressed(m_moveDownAction)  or event.is_action_released(m_moveUpAction)):
		m_movement.y += 1
	if (event.is_action_pressed(m_moveUpAction)    or event.is_action_released(m_moveDownAction)):
		m_movement.y -= 1
	if (event.is_action_pressed(m_moveLeftAction)  or event.is_action_released(m_moveRightAction)):
		m_movement.x -= 1
	if (event.is_action_pressed(m_moveRightAction) or event.is_action_released(m_moveLeftAction)):
		m_movement.x += 1

	m_movement.x = max( min(1, m_movement.x), -1)
	m_movement.y = max( min(1, m_movement.y), -1)


func setActions( actions ):
	assert( actions.size() >= PlayersActions.size() )
	m_moveUpAction    = actions[0]
	m_moveDownAction  = actions[1]
	m_moveLeftAction  = actions[2]
	m_moveRightAction = actions[3]


func processMovement(delta):
	if not is_network_master():
		return

	if get_tree().is_network_server():
		for unit in m_units:
			unit.setMovement( m_movement )
	elif m_movementSentToServer != m_movement:
		for unit in m_units:
			unit.rpc_id( Network.ServerId, "setMovement", m_movement )
		m_movementSentToServer = m_movement


func assignUnits( units ):
	assert( Network.isServer() )
	var unitsChanged = false
	for unit in units:
		if not unit in m_units:
			m_units.append(unit)
			unitsChanged = true

	if is_network_master():
		return

	if unitsChanged:
		var unitsNodePaths = []
		for unit in m_units:
			unitsNodePaths.append( unit.get_path() )

		rpc("updateAssignedUnits", unitsNodePaths)


func unassignUnits( units ):
	assert( Network.isServer() )
	var unitsChanged = false
	for unit in units:
		var unitPosition = m_units.find(unit)
		if unitPosition != -1:
			m_units.remove( unitPosition )
			unitsChanged = true

	if is_network_master():
		return

	if unitsChanged:
		var unitsNodePaths = []
		for unit in m_units:
			unitsNodePaths.append( unit.get_path() )

		rpc("updateAssignedUnits", unitsNodePaths)


master func updateAssignedUnits( unitsNodePaths ):
	var units = []
	for path in unitsNodePaths:
		units.append( get_node(path) )
	m_units = units


