extends KinematicBody2D
class_name UnitBase


const _cellSize := Vector2(32, 32)

export (float) var _speed              = 5.0 setget _setSpeed

var _currentMoveDirection              := Vector2(0, 0)
onready var _nameLabel                 :Label = $"Name"
onready var _movementTween             :Tween = $"Pivot/Tween"
onready var _pivot                     :Position2D


signal predelete()
signal changedPosition()
signal moved( direction ) # Vector2
signal clicked()


func _init():
	Debug.updateVariable("Unit count", +1, true)


func _enter_tree():
	_currentMoveDirection = Vector2(0, 0)
	_pivot.position = Vector2(0, 0)


func _ready():
	_movementTween.playback_speed = _speed
# warning-ignore:return_value_discarded
	_movementTween.connect("tween_completed", self, "_onTweenFinished")


func _onTweenFinished(object : Object, key : NodePath):
	if _currentMoveDirection && object == _pivot && key == ":position":
		emit_signal("moved", _currentMoveDirection)
		_currentMoveDirection = Vector2(0, 0)


func _notification(what):
	if what == NOTIFICATION_INSTANCED:
		_pivot                     = $"Pivot"
	elif what == NOTIFICATION_PREDELETE:
		emit_signal( "predelete" )
		Debug.updateVariable("Unit count", -1, true)


func _input_event(_viewport, event, _shape_idx):
	if event.is_action_pressed("ui_LMB"):
		emit_signal("clicked")


func moveInDirection( direction : Vector2 ):
	if _currentMoveDirection:
		return

	if not direction:
		return

	assert( abs(direction.x) in [0, 1] and abs(direction.y) in [0, 1] )

	var movementVector : Vector2 = _makeMovementVector( direction )
	assert( movementVector )

	if test_move( transform, movementVector ):
		return

	_currentMoveDirection = direction

	var duration = movementVector.length() / _cellSize.x
	print(duration)

	_movementTween.interpolate_property(
		_pivot,
		"position",
		- movementVector,
		Vector2(0, 0),
		duration,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN
		)
	position += movementVector
	emit_signal("changedPosition")

	_movementTween.start()


func setNameLabel( newName ):
	_nameLabel.text = newName


func getIcon() -> Texture:
	return $"Pivot/Sprite".texture


func die():
	queue_free()


func serialize():
	var dict := {
		"position" : position + _pivot.position,
		"moveDir" : _currentMoveDirection,
		}
	return dict


func deserialize( saveDict : Dictionary ):
	set_position( Vector2(saveDict["position"]) )

	if saveDict.has('moveDir'):
		var direction : Vector2 = saveDict["moveDir"]
		moveInDirection(direction)


func _makeMovementVector( direction : Vector2 ) -> Vector2:
	var x_add = direction.x if direction.x <= 0 else _cellSize.x
	var x_target = int( (position.x + x_add) / _cellSize.x ) * _cellSize.x
	var x_diff = x_target - position.x

	var y_add = direction.y if direction.y <= 0 else _cellSize.y
	var y_target = int( (position.y + y_add) / _cellSize.y ) * _cellSize.y
	var y_diff = y_target - position.y

	return Vector2(x_diff, y_diff)


func _setSpeed( speed : float ) -> void:
	_speed = speed
	if _movementTween != null:
		_movementTween.playback_speed = speed
