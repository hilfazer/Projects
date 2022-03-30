extends Panel


export(Color) var colorInactive
export(Color) var colorActive
export var printEvents := true

onready var _rectUp = $"ColorRectUp"
onready var _rectDown = $"ColorRectDown"
onready var _rectLeft = $"ColorRectLeft"
onready var _rectRight = $"ColorRectRight"
onready var _captureButton : CheckButton = $"CheckButton"


func _ready():
	for rect in [_rectUp, _rectDown, _rectLeft, _rectRight]:
		rect.color = colorInactive


func _unhandled_input(event):
	# released events will only be captured (handled) if pressed events were captured previously
	# letting them go will allow them to be captured by object that received pressed events previously

	if _captureButton.pressed and event.is_action_pressed("ui_up"):
		_rectUp.color = colorActive
	elif event.is_action_released("ui_up") and _rectUp.color == colorActive:
		_rectUp.color = colorInactive
	elif _captureButton.pressed and event.is_action_pressed("ui_down"):
		_rectDown.color = colorActive
	elif event.is_action_released("ui_down") and _rectDown.color == colorActive:
		_rectDown.color = colorInactive
	elif _captureButton.pressed and event.is_action_pressed("ui_left"):
		_rectLeft.color = colorActive
	elif event.is_action_released("ui_left") and _rectLeft.color == colorActive:
		_rectLeft.color = colorInactive
	elif _captureButton.pressed and event.is_action_pressed("ui_right"):
		_rectRight.color = colorActive
	elif event.is_action_released("ui_right") and _rectRight.color == colorActive:
		_rectRight.color = colorInactive
	else:
		return

	get_tree().set_input_as_handled()
	if printEvents and event.is_action_type():
		print_debug(event.as_text())

