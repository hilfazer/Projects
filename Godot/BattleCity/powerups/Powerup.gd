var m_stage


func pickup( tank ):
	get_node("PickupAction").execute( m_stage, tank )
	self.queue_free()
