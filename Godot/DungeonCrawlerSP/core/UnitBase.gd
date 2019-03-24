extends KinematicBody2D
class_name UnitBase

const Speed = 3
const UnitNameLabel = "Name"

export var _cellSize := Vector2(16, 16)
export (float) var _speed = 1.0

var _isMoving := false
onready var _nameLabel := $"Name"
onready var _animationPlayer := $"Pivot/AnimationPlayer"
onready var _tween := $"Pivot/Tween"
onready var _pivot := $"Pivot"


signal predelete()
signal changedPosition()
signal moved( direction ) # Vector2


func _init():
	Debug.updateVariable("Unit count", +1, true)


func _ready():
	_animationPlayer.playback_speed = _speed


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
	_animationPlayer.play("move")
	var duration : float = _animationPlayer.current_animation_length / \
		_animationPlayer.playback_speed
	_tween.interpolate_property(
		_pivot, "position", - direction * _cellSize, Vector2(), \
		duration, \
		Tween.TRANS_LINEAR, Tween.EASE_IN
		)
	position += direction * _cellSize
	emit_signal("changedPosition")

	_tween.start()

	yield( _animationPlayer, "animation_finished" )
	_isMoving = false
	emit_signal("moved", direction)
	return OK


func setNameLabel( newName ):
	_nameLabel.text = newName


func serialize():
	var dict := { x = position.x, y = position.y }

	if _pivot.position:
		dict['pivot_x'] = _pivot.position.x
		dict['pivot_y'] = _pivot.position.y
		dict['animationLeft'] = _animationPlayer.current_animation_length * \
			_animationPlayer.playback_speed - \
			_animationPlayer.current_animation_position
	return dict


func deserialize( saveDict ):
	set_position( Vector2(saveDict['x'], saveDict['y']) )
	if saveDict.has('animationLeft') and saveDict['animationLeft'] > 0.0:
		_animateMovement( Vector2(saveDict['pivot_x'], saveDict['pivot_y']), \
			saveDict['animationLeft'] )


func _animateMovement( from : Vector2, time : float ):
	_isMoving = true
	var speed = _animationPlayer.get_animation("move").length / time

	_animationPlayer.play("move", -1, speed)
	_tween.interpolate_property(
		_pivot, "position", from, Vector2(), \
		time, \
		Tween.TRANS_LINEAR, Tween.EASE_IN
		)

	_tween.start()

	yield( _animationPlayer, "animation_finished" )
	_isMoving = false


