extends KinematicBody2D

const Speed = 3
const UnitNameLabel = "Name"

slave var  m_slave_pos
master var m_movement = Vector2(0,0)


func _ready():
	set_fixed_process(true)
	m_slave_pos = self.position


func _fixed_process(delta):
	if ( get_tree().is_network_server() ):
		move( m_movement.normalized() * Speed )

		rset_unreliable("m_slave_pos", self.position)
	else:
		set_position(m_slave_pos)
		
		
remote func setMovement( movement ):
	m_movement = movement
	
	
func sendToClient(clientId):
	var unitData = {
		position = get_position(),
		nameLabelText = get_node(UnitNameLabel).get_text()
	}
	var nameLabelText = get_node(UnitNameLabel).get_text()
	rpc_id(clientId, "copyUnit", unitData)
	
	
remote func copyUnit(unitData):
	set_position(unitData.position)
	get_node(UnitNameLabel).text = unitData.nameLabelText
	
