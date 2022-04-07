extends KinematicBody2D

export var speed := 100
onready var nav_agent : NavigationAgent2D = $"NavigationAgent2D"
var _safe_velocity : Vector2


func _ready():
	nav_agent.set_target_location(global_position)
	$"PathDrawer".nav_agent = nav_agent


func _input(event):
	if event is InputEventMouseButton and event.is_action_pressed("move"):
		nav_agent.set_target_location(event.position)
		$"PathDrawer".update()
		nav_agent.set_velocity(Vector2(100, 100))


func _physics_process(delta):
	if nav_agent.is_navigation_finished():
		return
	else:
		var target = nav_agent.get_next_location()
		var vel = (target - global_position).normalized() * speed
		nav_agent.set_velocity(vel)

		var vec_to_move = _safe_velocity.normalized() * speed * delta
	# warning-ignore:return_value_discarded
		move_and_collide(vec_to_move)


func _on_NavigationAgent2D_velocity_computed(safe_velocity):
	_safe_velocity = safe_velocity



