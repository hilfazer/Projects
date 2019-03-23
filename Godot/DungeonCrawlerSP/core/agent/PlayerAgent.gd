extends AgentBase


func _physics_process(delta):
	var movement := Vector2(0, 0)

	if Input.is_action_pressed("ui_up"):
		movement.y -= 1
	if Input.is_action_pressed("ui_down"):
		movement.y += 1
	if Input.is_action_pressed("ui_left"):
		movement.x -= 1
	if Input.is_action_pressed("ui_right"):
		movement.x += 1

	if movement:
		for unit in _unitsInTree:
			assert( unit.is_inside_tree() )
			unit.moveInDirection( movement )

