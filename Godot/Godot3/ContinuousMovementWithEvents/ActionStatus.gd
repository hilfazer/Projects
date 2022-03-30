extends HBoxContainer


func _process(_delta):
	var actionsToLabels = {
		'ui_up' : $StatusUp, 'ui_down' : $StatusDown, 'ui_left' : $StatusLeft, 'ui_right' : $StatusRight
		}

	for a in actionsToLabels:
		if Input.is_action_pressed(a):
			actionsToLabels[a].text = a
		else:
			actionsToLabels[a].text = ""
