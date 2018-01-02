extends KinematicBody2D

const Speed = 3
const UnitNameLabel = "Name"

slave var  m_slave_pos
master var m_movement = Vector2(0,0)  setget setMovement


func _ready():
	m_slave_pos = self.position


func _physics_process(delta):
	if ( Network.isServer() ):
		if (m_movement != Vector2(0,0)):
			move_and_collide( m_movement.normalized() * Speed )

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


func setNameLabel( name ):
	get_node(UnitNameLabel).text = name


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
