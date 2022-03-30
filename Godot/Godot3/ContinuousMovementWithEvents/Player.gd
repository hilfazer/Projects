extends KinematicBody2D


export var speed : int = 300
export var printEvents := true

var _movementVector := Vector2.ZERO
var _up := 0
var _down := 0
var _left := 0
var _right := 0


func _unhandled_input(event):
	if event.is_action_pressed("ui_up"):
		_up = 1
	elif event.is_action_released("ui_up") and _up == 1:
		_up = 0
	elif event.is_action_pressed("ui_down"):
		_down = 1
	elif event.is_action_released("ui_down") and _down == 1:
		_down = 0
	elif event.is_action_pressed("ui_left"):
		_left = 1
	elif event.is_action_released("ui_left") and _left == 1:
		_left = 0
	elif event.is_action_pressed("ui_right"):
		_right = 1
	elif event.is_action_released("ui_right") and _right == 1:
		_right = 0
	else:
		return

	_updateMovementVector()
	get_tree().set_input_as_handled()
	if printEvents and event.is_action_type():
		print_debug(event.as_text())


func _physics_process(delta):
# warning-ignore:return_value_discarded
	move_and_collide(_movementVector.normalized() * delta * speed)


func _updateMovementVector() -> void:
	_movementVector.x = _right - _left
	_movementVector.y = _down - _up
