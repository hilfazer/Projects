extends KinematicBody2D

var speed = 100
var last_move_vec : Vector2
onready var nav_agent : NavigationAgent2D = $"NavigationAgent2D"


#func _ready():
#	nav_agent.set_target_location(Vector2.ZERO)



func _physics_process(delta):
	if nav_agent.is_navigation_finished():
		pass #linear_velocity = Vector2.ZERO
	else:
		var next_target = nav_agent.get_next_location()
		var vec_to_move = global_position.direction_to(next_target) * speed * delta
		move_and_collide(vec_to_move)
		last_move_vec = vec_to_move
		#print( target )
		#var vel = global_position.direction_to(target) * speed
		#$NavigationAgent2D.set_velocity(vel)


func _input(event):
	if event is InputEventMouseButton and event.is_action_pressed("move"):
		nav_agent.set_target_location(event.position)
		pass
