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

func tryDeleteMainMenu():
	if isGameInProgress():
		deleteMainMenu()

# called by MainMenu scene
func connectMainMenu( mainMenu ):
	m_mainMenu = mainMenu
	
	Network.connect("sendVariable",       mainMenu.get_node("Variables"), "updateVariable")

	Network.connect("connectionFailed",   mainMenu.get_node("Connect"), "onConnectionFailed")
	Network.connect("gameEnded",          mainMenu.get_node("Connect"), "onGameEnded")
	Network.connect("gameError",          mainMenu.get_node("Connect"), "onGameError")
	Network.connect("networkPeerChanged", mainMenu.get_node("Connect"), "onNetworkPeerChanged")

	Network.connect("networkPeerChanged", mainMenu.get_node("Lobby"), "onNetworkPeerChanged")
	Network.connect("playerListChanged",  mainMenu.get_node("Lobby"), "refreshLobby", [Network.m_players])
	Network.connect("playerJoined",       mainMenu.get_node("Lobby"), "sendToClient")
	
	mainMenu.get_node("Connect/Buttons/Stop").connect("pressed", Network, "endGame")
	mainMenu.get_node("Connect/Buttons/Stop").connect("pressed", self, "deleteGame")
	mainMenu.get_node("Connect/Buttons/Stop").connect("pressed", self, "createMainMenu")
	mainMenu.get_node("Lobby").connect("readyForGame", self, "createGame")
	mainMenu.connect("tryDelete", self, "tryDeleteMainMenu")

	connectMainMenuToGame( m_mainMenu, m_game )

func connectMainMenuToGame( mainMenu, game ):
	if !mainMenu or !game:
		return

	game.connect("gameEnded", mainMenu, "onGameEnded")
	mainMenu.get_node("Connect/Buttons/Stop").disabled = !isGameInProgress()

func createGame( module, playerUnits ):
	m_game = GameGd.new( module )
	get_tree().get_root().add_child( m_game )
	m_game.loadStartingLevel()
	m_game.placePlayerUnits(playerUnits)

func deleteGame():
	if m_game:
		m_game.queue_free()
		m_game = null

# called by Game scene
func connectGame( game ):
	assert( m_game == game )
	
	game.connect("gameStarted", self, "deleteMainMenu")
	connectMainMenuToGame( m_mainMenu, m_game )

func isGameInProgress():
	return m_game != null



