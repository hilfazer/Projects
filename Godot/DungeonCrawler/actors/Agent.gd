extends Node

const AgentsGroup = "Agents"
const NodeName = "Agent"

var m_unit = null


func _init():
	add_to_group(AgentsGroup)
	set_name(NodeName)


func _ready():
	set_process( is_network_master() )


func _process(delta):
	processMovement(delta)


func assignToUnit( unit ):
	for node in unit.get_children():
		if node.is_in_group(AgentsGroup):
			unit.remove_child(node)

	m_unit = unit
	m_unit.add_child( self )