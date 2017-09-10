extends KinematicBody2D

const Speed = 3
const UnitNameLabel = "Name"

slave var  m_slave_pos
master var m_movement = Vector2(0,0)  setget setMovement


func _ready():
	set_fixed_process(true)
	m_slave_pos = self.position


func _fixed_process(delta):
	if ( get_tree().has_network_peer() and get_tree().is_network_server() ):
		if (m_movement != Vector2(0,0)):
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

	rpc_id(clientId, "copyUnit", unitData)


remote func copyUnit(unitData):
	set_position(unitData.position)
	get_node(UnitNameLabel).text = unitData.nameLabelText


func save():
	var saveData = {
		scene = get_filename(),
		posX = get_position().x,
		posY = get_position().y
	}
	return saveData


func load(saveDict):
	set_position(Vector2(saveDict.posX, saveDict.posY))
