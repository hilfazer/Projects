extends Panel


func refreshLobby():
	var players = gamestate.m_players

	get_node("Players/PlayerList").clear()
	for p in players:
		var playerString = players[p] + " (" + str(p) + ") "
		playerString += " (You)" if p == get_tree().get_network_unique_id() else ""
		get_node("Players/PlayerList").add_item(playerString)
