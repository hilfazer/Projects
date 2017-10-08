extends Node

const MainMenuScn = "res://gui/MainMenu.tscn"
const GameGd = preload("res://modules/Game.gd")

var m_mainMenu setget deleted, deleted
var m_game     setget deleted, deleted


func deleted():
	assert(false)


func _init():
	set_pause_mode(PAUSE_MODE_PROCESS)

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		createMainMenu()

func createMainMenu():
	deleteMainMenu()
	var mainMenu = preload(MainMenuScn).instance()
	get_tree().get_root().add_child( mainMenu )

func deleteMainMenu():
	if m_mainMenu:
		m_mainMenu.set_name(m_mainMenu.get_name() + "_freeing")
		m_mainMenu.queue_free()
		m_mainMenu = null

func tryDeleteMainMenu():
	if isGameInProgress():
		deleteMainMenu()

# called by MainMenu scene
func connectMainMenu( mainMenu ):
	m_mainMenu = mainMenu
	
	Utilities.connect("sendVariable",       mainMenu.get_node("Variables"), "updateVariable")

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
	
	if Network.m_playerName != null:
		mainMenu.get_node("Connect/Name").text = Network.m_playerName
	if Network.m_ip != null:
		mainMenu.get_node("Connect/Ip").text = Network.m_ip

	connectMainMenuToGame( m_mainMenu, m_game )

func connectMainMenuToGame( mainMenu, game ):
	if !mainMenu or !game:
		return

	mainMenu.get_node("Connect/Buttons/Stop").disabled = !isGameInProgress()

remote func createGame( module, playerUnits ):
	if Network.isServer():
		rpc("createGame", null, null)
		m_game = GameGd.new( module, playerUnits )
		get_tree().get_root().add_child( m_game )
	else:
		m_game = GameGd.new()
		get_tree().get_root().add_child( m_game )

func deleteGame():
	if m_game:
		m_game.set_name(m_game.get_name() + "_freeing")
		m_game.queue_free()
		m_game = null

# called by Game scene
func connectGame( game ):
	assert( m_game == game )

	Network.connect("allPlayersReady", game, "start")
	game.connect("gameStarted", self, "deleteMainMenu")
	connectMainMenuToGame( m_mainMenu, m_game )

func isGameInProgress():
	return m_game != null



