extends Node2D

var nav_agent: NavigationAgent2D
var computed_velocity := Vector2.ZERO
onready var parent : Node2D = $".."


func _init():
	set_as_toplevel(true)


func _draw():
	if not is_instance_valid(nav_agent) or not is_instance_valid(parent):
		return

	drawPath(nav_agent.get_nav_path())
	drawVelocity(computed_velocity)


func drawPath(path : PoolVector2Array) -> void:
	for segment in path:
		draw_circle(segment, 4, Color.darkred)

	for i in range(0, path.size()-1):
		draw_line(path[i], path[i+1], Color.brown, 2.0)


func _on_NavigationAgent2D_velocity_computed(safe_velocity):
	computed_velocity = safe_velocity
	update()


func drawVelocity(vel):
	draw_line(parent.global_position, parent.global_position + computed_velocity, Color.blue)
