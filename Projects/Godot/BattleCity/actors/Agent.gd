const AgentGroup = "Agent"

var m_tank = null


func _init():
	add_to_group(AgentGroup)
	set_name(AgentGroup)


func _ready():
	set_process( true )


func _process(delta):
	processMovement(delta)
	processFiring(delta)


func assignToTank( tank ):
	for node in tank.get_children():
		if node.is_in_group(AgentGroup):
			tank.remove_child(node)

	m_tank = tank
	m_tank.add_child( self )