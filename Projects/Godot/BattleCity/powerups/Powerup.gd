var m_stage


func pickup( playerId ):
	get_node("PickupAction").execute( m_stage, playerId )
	self.queue_free()
