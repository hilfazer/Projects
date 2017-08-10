extends KinematicBody2D

slave var slave_pos


func _ready():
	set_fixed_process(true)
	slave_pos = self.position


func _fixed_process(delta):
	if ( is_network_master() ):
		if( Input.is_action_pressed("up") ):
			move(Vector2(0, -1))
		if( Input.is_action_pressed("down") ):
			move(Vector2(0, 1))
		if( Input.is_action_pressed("left") ):
			move(Vector2(-1, 0))
		if( Input.is_action_pressed("right") ):
			move(Vector2(1, 0))

		rset_unreliable("slave_pos", self.position)
	else:
		set_position(slave_pos)