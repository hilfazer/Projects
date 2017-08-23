extends Control

func _ready():
	gamestate.connect("connectionFailed", self, "onConnectionFailed")
	gamestate.connect("connectionSucceeded", self, "onConnectionSuccess")
	gamestate.connect("playerListChanged", self, "refreshLobby")
	gamestate.connect("gameEnded", self, "onGameEnded")
	gamestate.connect("gameError", self, "onGameError")
	
	gamestate.connect("sendVariable", get_node("variables"), "updateVariable")
	gamestate.connect("networkPeerChanged", self, "onNetworkPeerChanged")
	get_node("connect/name").set_text( str(gamestate.m_playerName) )


func onHostPressed():
	if (get_node("connect/name").text == ""):
		get_node("connect/error_label").text="Invalid name!"
		return

	get_node("connect/error_label").text=""

	var name = get_node("connect/name").text
	gamestate.hostGame(name)
	refreshLobby()

func onJoinPressed():
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
	# refreshLobby() gets called by the playerListChanged signal

func onConnectionSuccess():
	get_node("connect").hide()

func onConnectionFailed():
	get_node("connect/host").disabled=false
	get_node("connect/join").disabled=false
	get_node("connect/error_label").set_text("Connection failed.")

func onGameEnded():
	show()
	get_node("connect").show()
	get_node("connect/host").disabled=false
	get_node("connect/join").disabled=false

func onGameError(errtxt):
	get_node("error").dialog_text=errtxt
	get_node("error").popup_centered_minsize()
	get_node("connect/host").disabled=false
	get_node("connect/join").disabled=false

func refreshLobby():
	var players = gamestate.m_players

	get_node("players/list").clear()
	for p in players:
		var playerString = players[p] + " (" + str(p) + ") "
		playerString += " (You)" if p == get_tree().get_network_unique_id() else ""
		get_node("players/list").add_item(playerString)

	get_node("players/start").disabled=not get_tree().is_network_server()

func onStartPressed():
	gamestate.beginGame()
	get_node("players/stop").disabled= false


func onStopPressed():
	gamestate.endGame()
	get_node("players/stop").disabled= true
	
	
func onNetworkPeerChanged():
	get_node("players/start").disabled= \
		not (get_tree().has_network_peer() and get_tree().is_network_server() )
	get_node("players/stop").disabled=not get_tree().has_network_peer()
	
