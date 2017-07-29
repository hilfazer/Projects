func execute( stage, playerId ):
	var lives = stage.get_ref().get_node("Frame").getPlayerLives(playerId)
	stage.get_ref().get_node("Frame").setPlayerLives(playerId, lives + 1)