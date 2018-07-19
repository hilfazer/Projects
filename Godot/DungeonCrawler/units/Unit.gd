extends KinematicBody2D

const Speed = 3
const UnitNameLabel = "Name"

slave var  m_slave_pos
master var m_movement = Vector2(0,0)  setget setMovement
var m_rpcTargets = []             setget setRpcTargets


func _ready():
	m_slave_pos = self.position


func _physics_process(delta):
	if ( Network.isServer() ):
		if (m_movement != Vector2(0,0)):
			var previousPos = self.position
			move_and_collide( m_movement.normalized() * Speed )

			if self.position != previousPos:
				Network.RSETu(self, ["m_slave_pos", self.position] )
	else:
		set_position(m_slave_pos)


func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		pass


remote func setMovement( movement ):
	m_movement = movement


func setNameLabel( newName ):
	get_node(UnitNameLabel).text = newName


func setRpcTargets( clientIds ):
	m_rpcTargets = clientIds


func sendToClient(clientId):
	var unitData = {
		position = get_position(),
		nameLabelText = get_node(UnitNameLabel).get_text()
	}

	rpc_id(clientId, "copyUnit", unitData)


remote func copyUnit(unitData):
	m_slave_pos = unitData.position
	get_node(UnitNameLabel).text = unitData.nameLabelText


func serialize():
	var saveData = {
		scene = get_filename(),
		posX = get_position().x,
		posY = get_position().y,
		nameLabel = get_node(UnitNameLabel).text
	}
	return saveData


func deserialize(saveDict):
	set_position( Vector2(saveDict.posX, saveDict.posY) )
	m_slave_pos = position
	get_node(UnitNameLabel).text = saveDict.nameLabel

