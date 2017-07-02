var m_stage


func pickup():
	get_node("PickupAction").execute( m_stage )
	self.queue_free()