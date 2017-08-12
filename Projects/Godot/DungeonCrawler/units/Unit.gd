extends KinematicBody2D

slave var slave_pos
var m_movement = Vector2(0,0)


func _ready():
	set_fixed_process(true)
	slave_pos = self.position


func _fixed_process(delta):
	if ( get_tree().is_network_server() ):
		move( m_movement.normalized() )
		m_movement = Vector2(0,0)

		rset_unreliable("slave_pos", self.position)
	else:
		set_position(slave_pos)
		
		
remote func setMovement( movement ):
	m_movement = movement
	