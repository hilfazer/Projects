extends Control

onready var _pause = visible
onready var _sceneRoot = $"../.."


func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		_pause = !_pause
		visible = _pause
		_sceneRoot.updatePaused()
