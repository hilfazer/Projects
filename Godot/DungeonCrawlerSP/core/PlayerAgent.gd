extends Node

const UnitBaseGd     = preload("res://core/UnitBase.gd")

var _unit : UnitBaseGd


func _enter_tree():
	_unit = get_parent()
	set_physics_process( _unit.is_inside_tree() )
	_unit.connect( "tree_entered", self, "set_physics_process", [true]  )
	_unit.connect( "tree_exited" , self, "set_physics_process", [false] )


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
		_unit.moveInDirection( movement )
