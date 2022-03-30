extends Node


var _actionsToRelease := ["ui_up", "ui_down", "ui_left", "ui_right"]


func _notification(what):
	if what == NOTIFICATION_WM_FOCUS_OUT:
		for action in _actionsToRelease:
			var ev = InputEventAction.new()
			ev.action = action
			ev.pressed = false
			Input.parse_input_event(ev)
