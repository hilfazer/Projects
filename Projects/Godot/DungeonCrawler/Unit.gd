extends KinematicBody2D


func _ready():
	set_process(true)
	
	
func _process(delta):
	if ( is_network_master() ):
		if( Input.is_action_pressed("up") ):
			move(Vector2(0, -1))
		if( Input.is_action_pressed("down") ):
			move(Vector2(0, 1))
		if( Input.is_action_pressed("left") ):
			move(Vector2(-1, 0))
		if( Input.is_action_pressed("right") ):
			move(Vector2(1, 0))
