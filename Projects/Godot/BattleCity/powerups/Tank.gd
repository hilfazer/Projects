

func execute( stage, tank ):
	var playerId = tank.get_node("Agent").m_playerId
	var lives = stage.get_ref().get_node("Frame").getPlayerLives(playerId)
	stage.get_ref().get_node("Frame").setPlayerLives(playerId, lives + 1)
