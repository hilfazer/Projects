extends Node

const AgentsGroup = "Agents"

var m_unit  setget deleted


func deleted():
	assert(false)


func _init():
	add_to_group(AgentsGroup)


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