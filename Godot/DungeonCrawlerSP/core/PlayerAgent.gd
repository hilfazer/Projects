extends Node

const UnitBaseGd     = preload("res://core/UnitBase.gd")

var m_unit : UnitBaseGd


func _enter_tree():
	m_unit = get_parent()
	set_physics_process( m_unit.is_inside_tree() )
	m_unit.connect( "tree_entered", self, "set_physics_process", [true]  )
	m_unit.connect( "tree_exited" , self, "set_physics_process", [false] )


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

	m_unit.setMovement( movement )
