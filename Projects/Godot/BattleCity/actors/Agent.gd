extends Node

const AgentsGroup = "Agents"
const NodeName = "Agent"

var m_tank = null


func _init():
	add_to_group(AgentsGroup)
	set_name(NodeName)


func _ready():
	set_process( true )
	set_fixed_process( true )


func _process(delta):
	processMovement(delta)
	processFiring(delta)


func _fixed_process(delta):
	processMovement(delta)


func assignToTank( tank ):
	for node in tank.get_children():
		if node.is_in_group(AgentsGroup):
			tank.remove_child(node)

	m_tank = tank
	m_tank.add_child( self )