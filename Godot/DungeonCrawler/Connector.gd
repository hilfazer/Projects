extends Node

const MainMenuScn = "res://gui/MainMenu.tscn"
const GameGd = preload("res://modules/Game.gd")

var m_mainMenu
var m_game


func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		createMainMenu()


func createMainMenu():
	deleteMainMenu()
	var mainMenu = preload(MainMenuScn).instance()
	get_tree().get_root().add_child( mainMenu )


func deleteMainMenu():
	if m_mainMenu:
		m_mainMenu.queue_free()
		m_mainMenu = null

# called by MainMenu scene
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
	
	mainMenu.get_node("Connect/Buttons/Stop").connect("pressed", gamestate, "endGame")
	mainMenu.get_node("Connect/Buttons/Stop").connect("pressed", self, "deleteGame")
	mainMenu.get_node("Connect/Buttons/Stop").connect("pressed", self, "createMainMenu")
	mainMenu.get_node("Lobby").connect("readyForGame", self, "createGame")

	connectMainMenuToGame( m_mainMenu, m_game )


func connectMainMenuToGame( mainMenu, game ):
	if !mainMenu or !game:
		return

	game.connect("gameEnded", mainMenu, "onGameEnded")
	mainMenu.get_node("Connect/Buttons/Stop").disabled = !m_game


func createGame( module, playerUnits ):
	m_game = GameGd.new( module )
	get_tree().get_root().add_child( m_game )
	m_game.loadStartingLevel()
	m_game.placePlayerUnits(playerUnits)


func deleteGame():
	if m_game:
		m_game.queue_free()
		m_game = null

# collect by Game scene
func connectGame( game ):
	assert( m_game == game )
	
	game.connect("gameStarted", self, "deleteMainMenu")
	connectMainMenuToGame( m_mainMenu, m_game )
	





