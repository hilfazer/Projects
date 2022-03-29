extends KinematicBody2D


export var speed : int = 300

var _movementVector := Vector2.ZERO


func _unhandled_input(event):
	if event.is_action_type():
		print_debug(event.as_text())

	if event.is_action_pressed("ui_up") or event.is_action_released("ui_down"):
		_updateMovementVector(Vector2.UP)
	elif event.is_action_released("ui_up") or event.is_action_pressed("ui_down"):
		_updateMovementVector(Vector2.DOWN)
	elif event.is_action_pressed("ui_left") or event.is_action_released("ui_right"):
		_updateMovementVector(Vector2.LEFT)
	elif event.is_action_released("ui_left") or event.is_action_pressed("ui_right"):
		_updateMovementVector(Vector2.RIGHT)
	else:
		return

	get_tree().set_input_as_handled()


func _physics_process(delta):
# warning-ignore:return_value_discarded
	move_and_collide(_movementVector.normalized() * delta * speed)


func _updateMovementVector(direction : Vector2) -> void:
	_movementVector += direction
