extends KinematicBody2D

const Speed = 3
const UnitNameLabel = "Name"

var m_movement = Vector2(0,0)          setget setMovement
onready var m_nameLabel = $"Name"


signal predelete()


func _init():
	Debug.updateVariable("Unit count", +1, true)


func _physics_process(delta):
	if (m_movement != Vector2(0,0)):
		move_and_collide( m_movement.normalized() * Speed )


func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		emit_signal( "predelete" )
		Debug.updateVariable("Unit count", -1, true)


func setMovement( movement : Vector2 ):
	m_movement = movement


func setNameLabel( newName ):
	m_nameLabel.text = newName


func serialize():
	var saveData = {
		posX = get_position().x,
		posY = get_position().y,
	}
	return saveData


func deserialize(saveDict):
	set_position( Vector2(saveDict.posX, saveDict.posY) )

