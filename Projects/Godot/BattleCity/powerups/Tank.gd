

func execute( stage, tank ):
	var playerId = tank.get_node("Agent").m_playerId
	
	stage.m_params.playerData[playerId].lives += 1
	stage.get_ref().get_node("Frame").setPlayerLives(playerId, stage.m_params.playerData[playerId].lives)
