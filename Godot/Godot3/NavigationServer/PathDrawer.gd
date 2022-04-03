extends Node2D

var nav_agent: NavigationAgent2D


func _init():
	set_as_toplevel(true)


func _draw():
	nav_agent && drawPath(nav_agent.get_nav_path())


func drawPath(path : PoolVector2Array) -> void:
	for segment in path:
		draw_circle(segment, 4, Color.darkred)

	for i in range(0, path.size()-1):
		draw_line(path[i], path[i+1], Color.brown, 2.0)
