extends Control

func _ready():
	gamestate.connect("connectionFailed", self, "_on_connection_failed")
	gamestate.connect("connectionSucceeded", self, "_on_connection_success")
	gamestate.connect("playerListChanged", self, "refresh_lobby")
	gamestate.connect("gameEnded", self, "_on_game_ended")
	gamestate.connect("gameError", self, "_on_game_error")
	
	gamestate.connect("sendVariable", get_node("variables"), "updateVariable")
	gamestate.connect("networkPeerChanged", self, "onNetworkPeerChanged")
	get_node("connect/name").set_text( str(gamestate.m_playerName) )


func _on_host_pressed():
	if (get_node("connect/name").text == ""):
		get_node("connect/error_label").text="Invalid name!"
		return

	get_node("connect/error_label").text=""

	var name = get_node("connect/name").text
	gamestate.hostGame(name)
	refresh_lobby()

func _on_join_pressed():
	if (get_node("connect/name").text == ""):
		get_node("connect/error_label").text="Invalid name!"
		return

	var ip = get_node("connect/ip").text
	if (not ip.is_valid_ip_address()):
		get_node("connect/error_label").text="Invalid IPv4 address!"
		return

	get_node("connect/error_label").text=""
	get_node("connect/host").disabled=true
	get_node("connect/join").disabled=true

	var name = get_node("connect/name").text
	gamestate.joinGame(ip, name)
	# refresh_lobby() gets called by the playerListChanged signal

func _on_connection_success():
	get_node("connect").hide()

func _on_connection_failed():
	get_node("connect/host").disabled=false
	get_node("connect/join").disabled=false
	get_node("connect/error_label").set_text("Connection failed.")

func _on_game_ended():
	show()
	get_node("connect").show()
	get_node("connect/host").disabled=false
	get_node("connect/join").disabled=false

func _on_game_error(errtxt):
	get_node("error").dialog_text=errtxt
	get_node("error").popup_centered_minsize()
	get_node("connect/host").disabled=false
	get_node("connect/join").disabled=false

func refresh_lobby():
	var players = gamestate.getPlayerList()

	get_node("players/list").clear()
	for p in players:
		var playerString = players[p] + " (" + str(p) + ") "
		playerString += " (You)" if p == get_tree().get_network_unique_id() else ""
		get_node("players/list").add_item(playerString)

	get_node("players/start").disabled=not get_tree().is_network_server()

func _on_start_pressed():
	gamestate.beginGame()
	get_node("players/stop").disabled= false


func _on_stop_pressed():
	gamestate.endGame()
	get_node("players/stop").disabled= true
	
	
func onNetworkPeerChanged():
	get_node("players/start").disabled=not get_tree().is_network_server()
	get_node("players/stop").disabled=not get_tree().has_network_peer()
	
