extends "Agent.gd"

const UnitBaseGd = preload("res://core/UnitBase.gd")

const PlayersActions = [
	["move_up", "move_down", "move_left", "move_right"]
]

enum Direction { UP = 0, DOWN = 1, LEFT = 2, RIGHT = 3 }

var m_moveUpAction
var m_moveDownAction
var m_moveLeftAction
var m_moveRightAction

var m_directions = PoolByteArray([0,0,0,0])      setget deleted # 4 directions, either 0 or 1
var m_lastMovement

#nodes
var m_units = []                       setget deleted


signal unitsAssigned( nodes )
signal unitsUnassigned( nodes )


func deleted(_a):
	assert(false)


func _init():
	# set default actions
	setActions( PlayersActions[0] )
	add_to_group(GlobalGd.Groups.PlayerAgents)


func _unhandled_input(event):
	assert( is_network_master() )
	if not is_network_master():
		return

	if event.is_action_pressed(m_moveUpAction):
		m_directions[Direction.UP] = 1
	elif event.is_action_released(m_moveUpAction):
		m_directions[Direction.UP] = 0
	if event.is_action_pressed(m_moveDownAction):
		m_directions[Direction.DOWN] = 1
	elif event.is_action_released(m_moveDownAction):
		m_directions[Direction.DOWN] = 0
	if event.is_action_pressed(m_moveLeftAction):
		m_directions[Direction.LEFT] = 1
	elif event.is_action_released(m_moveLeftAction):
		m_directions[Direction.LEFT] = 0
	if event.is_action_pressed(m_moveRightAction):
		m_directions[Direction.RIGHT] = 1
	elif event.is_action_released(m_moveRightAction):
		m_directions[Direction.RIGHT] = 0


func setActions( actions : Array ):
	assert( actions.size() >= PlayersActions.size() )
	m_moveUpAction    = actions[0]
	m_moveDownAction  = actions[1]
	m_moveLeftAction  = actions[2]
	m_moveRightAction = actions[3]


func processMovement( delta : float ):
	assert( is_network_master() )

	var movement = Vector2( m_directions[Direction.RIGHT] - m_directions[Direction.LEFT], \
							m_directions[Direction.DOWN]  - m_directions[Direction.UP] )

	if m_lastMovement != movement:
		if get_tree().is_network_server():
			for unit in m_units:
				if unit.is_inside_tree():
					unit.setMovement( movement )
		else:
			for unit in m_units:
				if unit.is_inside_tree():
					Network.RPCmaster( unit, ["setMovement", movement] )
		m_lastMovement = movement


func assignUnits( units : Array ):
	assert( Network.isServer() )
	var assignedUnits = []

	for unit in units:
		assert( unit is UnitBaseGd )
		if not unit in m_units:
			assignedUnits.append( unit )
			_addUnit( unit )

	if not assignedUnits.empty():
		emit_signal("unitsAssigned", assignedUnits)

		if is_network_master():
			return

		var unitsNodePaths = []
		for unit in m_units:
			if unit.is_inside_tree():
				unitsNodePaths.append( unit.get_path() )

		rpc("updateAssignedUnits", unitsNodePaths)


func unassignUnits( units : Array ):
	assert( Network.isServer() )
	var unassignedUnits = []

	for unit in units:
		assert( unit is UnitBaseGd )
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
			assert( unit is UnitBaseGd )
			if unit.is_inside_tree():
				unitsNodePaths.append( unit.get_path() )

		rpc("updateAssignedUnits", unitsNodePaths)


master func updateAssignedUnits( unitsNodePaths : Array ):
	if not get_tree().get_rpc_sender_id() == Network.ServerId:
		return

	for path in unitsNodePaths:
		if $'/root'.has_node( path ):
			var unit = $'/root'.get_node( path )
			assert( unit is UnitBaseGd )
			if unit:
				_addUnit( get_node(path) )


func _addUnit( unit : UnitBaseGd ):
	assert( unit )
	assert( not m_units.has( unit ) )
	m_units.append( unit )
	unit.connect( "predelete", self, "_removeUnit", [unit] )


func _removeUnit( unit : Node ):
	m_units.remove( m_units.find( unit ) )
