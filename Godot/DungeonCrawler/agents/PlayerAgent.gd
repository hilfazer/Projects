extends "Agent.gd"

const UnitGd                 = preload("res://units/Unit.gd")

const PlayersActions = [
	["move_up", "move_down", "move_left", "move_right"]
]

enum Direction { UP = 0, DOWN = 1, LEFT = 2, RIGHT = 3 }

var m_moveUpAction
var m_moveDownAction
var m_moveLeftAction
var m_moveRightAction

var m_directions = PoolByteArray([0,0,0,0])      setget deleted # 4 directions, either 0 or 1
slave var m_movementSentToServer

var m_units = []                       setget deleted


signal unitsAssigned( nodes )
signal unitsUnassigned( nodes )


func deleted(_a):
	assert(false)


func _init():
	# set default actions
	setActions( PlayersActions[0] )


func _unhandled_input(event):
	if not is_network_master():
		return

	if event.is_action_pressed(m_moveUpAction):
		m_directions[UP] = 1
	elif event.is_action_released(m_moveUpAction):
		m_directions[UP] = 0
	if event.is_action_pressed(m_moveDownAction):
		m_directions[DOWN] = 1
	elif event.is_action_released(m_moveDownAction):
		m_directions[DOWN] = 0
	if event.is_action_pressed(m_moveLeftAction):
		m_directions[LEFT] = 1
	elif event.is_action_released(m_moveLeftAction):
		m_directions[LEFT] = 0
	if event.is_action_pressed(m_moveRightAction):
		m_directions[RIGHT] = 1
	elif event.is_action_released(m_moveRightAction):
		m_directions[RIGHT] = 0


func setActions( actions ):
	assert( actions.size() >= PlayersActions.size() )
	m_moveUpAction    = actions[0]
	m_moveDownAction  = actions[1]
	m_moveLeftAction  = actions[2]
	m_moveRightAction = actions[3]


func processMovement(delta : float):
	if not is_network_master():
		return

	var movement = Vector2( m_directions[RIGHT] - m_directions[LEFT], \
							m_directions[DOWN]  - m_directions[UP] )
	if get_tree().is_network_server():
		for unit in m_units:
			unit.setMovement( movement )
	elif m_movementSentToServer != movement:
		for unit in m_units:
			unit.rpc_id( Network.ServerId, "setMovement", movement )
		m_movementSentToServer = movement


func assignUnits( units ):
	assert( Network.isServer() )
	var assignedUnits = []

	for unit in units:
		if not unit in m_units:
			assignedUnits.append( unit )
			m_units.append(unit)

	if not assignedUnits.empty():
		emit_signal("unitsAssigned", assignedUnits)

		if is_network_master():
			return

		var unitsNodePaths = []
		for unit in m_units:
			unitsNodePaths.append( unit.get_path() )

		rpc("updateAssignedUnits", unitsNodePaths)


func unassignUnits( units ):
	assert( Network.isServer() )
	var unassignedUnits = []

	for unit in units:
		var unitPosition = m_units.find(unit)
		if unitPosition != -1:
			unassignedUnits.append( m_units[unitPosition] )
			m_units.remove( unitPosition )

	if not unassignedUnits.empty():
		emit_signal("unitsUnassigned", unassignedUnits)

		if is_network_master():
			return

		var unitsNodePaths = []
		for unit in m_units:
			unitsNodePaths.append( unit.get_path() )

		rpc("updateAssignedUnits", unitsNodePaths)


master func updateAssignedUnits( unitsNodePaths ):
	var units = []
	for path in unitsNodePaths:
		units.append( get_node(path) )
	m_units = units


