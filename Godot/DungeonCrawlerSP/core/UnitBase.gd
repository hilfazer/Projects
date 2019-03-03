extends KinematicBody2D

const Speed = 3
const UnitNameLabel = "Name"

export var m_cellSize := Vector2(16, 16)
var m_isMoving := false
onready var m_nameLabel = $"Name"


signal predelete()
signal changedPosition()


func _init():
	Debug.updateVariable("Unit count", +1, true)


func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		emit_signal( "predelete" )
		Debug.updateVariable("Unit count", -1, true)


func moveInDirection( direction : Vector2 ):
	if m_isMoving:
		return 1

	assert( abs(direction.x) in [0, 1] and abs(direction.y) in [0, 1] )
	var collided = test_move( transform, direction * m_cellSize )
	if test_move( transform, direction * m_cellSize ):
		return 3

	m_isMoving = true
	$'Pivot/AnimationPlayer'.play("move")
	$'Pivot/Tween'.interpolate_property(
		$'Pivot', "position", - direction * m_cellSize, Vector2(), \
		$'Pivot/AnimationPlayer'.current_animation_length, \
		Tween.TRANS_LINEAR, Tween.EASE_IN
		)
	position += direction * m_cellSize
	emit_signal("changedPosition")

	$'Pivot/Tween'.start()

	yield( $'Pivot/AnimationPlayer', "animation_finished" )
	m_isMoving = false
	return OK


func setNameLabel( newName ):
	m_nameLabel.text = newName


func serialize():
	return {
		x = position.x,
		y = position.y
	}


func deserialize( saveDict ):
	set_position( Vector2(saveDict['x'], saveDict['y']) )

