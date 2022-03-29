extends Panel


export(Color) var colorInactive
export(Color) var colorActive

onready var _rectUp = $"ColorRectUp"
onready var _rectDown = $"ColorRectDown"
onready var _rectLeft = $"ColorRectLeft"
onready var _rectRight = $"ColorRectRight"
onready var _captureButton : CheckButton = $"CheckButton"


func _ready():
	for rect in [_rectUp, _rectDown, _rectLeft, _rectRight]:
		rect.color = colorInactive


# key inputs go here, not to _gui_input
func _unhandled_input(event):
	if event.is_action_type():
		print_debug(event.as_text())

	if not _captureButton.pressed:
		return

	if event.is_action_pressed("ui_up"):
		_rectUp.color = colorActive
	elif event.is_action_released("ui_up"):
		_rectUp.color = colorInactive
	elif event.is_action_pressed("ui_down"):
		_rectDown.color = colorActive
	elif event.is_action_released("ui_down"):
		_rectDown.color = colorInactive
	elif event.is_action_pressed("ui_left"):
		_rectLeft.color = colorActive
	elif event.is_action_released("ui_left"):
		_rectLeft.color = colorInactive
	elif event.is_action_pressed("ui_right"):
		_rectRight.color = colorActive
	elif event.is_action_released("ui_right"):
		_rectRight.color = colorInactive
	else:
		return

	get_tree().set_input_as_handled()
