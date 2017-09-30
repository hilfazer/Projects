extends Node

const MainMenuScn = "res://gui/MainMenu.tscn"

var m_mainMenu


func _ready():
	pass


func connectMainMenu( mainMenu ):
	m_mainMenu = mainMenu
	
	gamestate.connect("sendVariable",       mainMenu.get_node("Variables"), "updateVariable")

	gamestate.connect("connectionFailed",   mainMenu.get_node("Connect"), "onConnectionFailed")
	gamestate.connect("gameEnded",          mainMenu.get_node("Connect"), "onGameEnded")
	gamestate.connect("gameError",          mainMenu.get_node("Connect"), "onGameError")
	gamestate.connect("networkPeerChanged", mainMenu.get_node("Connect"), "onNetworkPeerChanged")

	gamestate.connect("networkPeerChanged", mainMenu.get_node("Lobby"), "onNetworkPeerChanged")
	gamestate.connect("playerListChanged",  mainMenu.get_node("Lobby"), "refreshLobby", [gamestate.m_players])
	gamestate.connect("playerJoined",       mainMenu.get_node("Lobby"), "sendToClient")
	
	mainMenu.get_node("Connect/Buttons/Stop").connect("pressed", self, "createMainMenu")


func createMainMenu():
	if m_mainMenu:
		m_mainMenu.queue_free()
		m_mainMenu = null

	var mainMenu = preload(MainMenuScn).instance()
	get_tree().get_root().add_child( mainMenu )