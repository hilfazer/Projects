extends CharacterBody2D


@onready var navAgent : NavigationAgent2D = $"NavigationAgent2D"


func getNavAgent():
	return navAgent


func _input(event):
	if event is InputEventMouseButton and event.is_action_pressed("move"):
		navAgent.set_target_location(event.position)


func _process(delta):
	if navAgent.is_navigation_finished():
		return
		
	global_position.direction_to(navAgent.get_next_location())
