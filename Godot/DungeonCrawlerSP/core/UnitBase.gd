extends KinematicBody2D
class_name UnitBase

const Speed = 3
const UnitNameLabel = "Name"

export var _cellSize := Vector2(16, 16)
var _isMoving := false
onready var _nameLabel = $"Name"


signal predelete()
signal changedPosition()


func _init():
	Debug.updateVariable("Unit count", +1, true)


func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		emit_signal( "predelete" )
		Debug.updateVariable("Unit count", -1, true)


func moveInDirection( direction : Vector2 ):
	if _isMoving:
		return 1

	assert( abs(direction.x) in [0, 1] and abs(direction.y) in [0, 1] )
	var collided = test_move( transform, direction * _cellSize )
	if test_move( transform, direction * _cellSize ):
		return 3

	_isMoving = true
	$'Pivot/AnimationPlayer'.play("move")
	$'Pivot/Tween'.interpolate_property(
		$'Pivot', "position", - direction * _cellSize, Vector2(), \
		$'Pivot/AnimationPlayer'.current_animation_length, \
		Tween.TRANS_LINEAR, Tween.EASE_IN
		)
	position += direction * _cellSize
	emit_signal("changedPosition")

	$'Pivot/Tween'.start()

	yield( $'Pivot/AnimationPlayer', "animation_finished" )
	_isMoving = false
	return OK


func setNameLabel( newName ):
	_nameLabel.text = newName


func serialize():
	var dict := { x = position.x, y = position.y }

	if $'Pivot'.position:
		dict['pivot_x'] = $'Pivot'.position.x
		dict['pivot_y'] = $'Pivot'.position.y
		dict['animationLeft'] = $'Pivot/AnimationPlayer'.current_animation_length - \
			$'Pivot/AnimationPlayer'.current_animation_position
	return dict


func deserialize( saveDict ):
	set_position( Vector2(saveDict['x'], saveDict['y']) )
	if saveDict.has('animationLeft') and saveDict['animationLeft'] > 0.0:
		_animateMovement( Vector2(saveDict['pivot_x'], saveDict['pivot_y']), \
			saveDict['animationLeft'] )


func _animateMovement( from : Vector2, time : float ):
	_isMoving = true
	var speed = $'Pivot/AnimationPlayer'.get_animation("move").length / time

	$'Pivot/AnimationPlayer'.play("move", -1, speed)
	$'Pivot/Tween'.interpolate_property(
		$'Pivot', "position", from, Vector2(), \
		time, \
		Tween.TRANS_LINEAR, Tween.EASE_IN
		)

	$'Pivot/Tween'.start()

	yield( $'Pivot/AnimationPlayer', "animation_finished" )
	_isMoving = false


