extends KinematicBody2D

const Speed = 3

slave var  m_slave_pos
master var m_movement = Vector2(0,0)


func _ready():
	set_fixed_process(true)
	m_slave_pos = self.position


func _fixed_process(delta):
	if ( get_tree().is_network_server() ):
		move( m_movement.normalized() * Speed )

		rset_unreliable("m_slave_pos", self.position)
	else:
		set_position(m_slave_pos)
		
		
remote func setMovement( movement ):
	m_movement = movement
	