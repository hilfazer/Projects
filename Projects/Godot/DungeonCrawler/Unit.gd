extends KinematicBody2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	set_process(true)
	
	
func _process(delta):
	if ( is_network_master() ):
		if( Input.is_action_pressed("ui_up") ):
			move(Vector2(0, -1))
		if( Input.is_action_pressed("ui_down") ):
			move(Vector2(0, 1))
		if( Input.is_action_pressed("ui_left") ):
			move(Vector2(-1, 0))
		if( Input.is_action_pressed("ui_right") ):
			move(Vector2(1, 0))
