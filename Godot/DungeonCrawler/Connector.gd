extends Node

const MainMenuScn = "res://gui/MainMenu.tscn"
const DebugWindowScn = "res://debug/DebugWindow.tscn"
const LoadingScreenScn = "res://gui/LoadingScreen.tscn"
const GameScn = "res://game/Game.tscn"

var m_mainMenu    setget deleted, deleted
var m_game        setget deleted, deleted
var m_debugWindow setget deleted, deleted


func deleted():
	assert(false)


func _init():
	set_pause_mode(PAUSE_MODE_PROCESS)


func _ready():
	Network.connect("networkError", self, "showAcceptDialog", ["Connection error"])
	call_deferred("createDebugWindow")


func createDebugWindow():
	get_tree().get_root().add_child( preload(DebugWindowScn).instance() )


func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		createMainMenu()


func createMainMenu():
	deleteMainMenu()
	var mainMenu = preload(MainMenuScn).instance()
	get_tree().get_root().add_child( mainMenu )


func deleteMainMenu():
	Utility.setFreeing( m_mainMenu )
	m_mainMenu = null


# called by MainMenu scene
func connectMainMenu( mainMenu ):
	m_mainMenu = mainMenu


func connectHostNewGame( hostNewGame ):
	Network.connect("networkError",       hostNewGame, "onNetworkError")
	Network.connect("playerListChanged",  hostNewGame.get_node("Lobby"), "refreshLobby", [Network.m_players])
	Network.connect("playerJoined",       hostNewGame.get_node("Lobby"), "sendToClient")
	hostNewGame.connect("readyForGame",   self, "createGame")


func connectDebugWindow( debugWindow ):
	m_debugWindow = debugWindow
	Utility.connect("sendVariable", debugWindow, "updateVariable")


remote func createGame( module, playerUnits ):
	if Network.isServer():
		SceneSwitcher.switchScene( GameScn, [module, playerUnits] )
		rpc("createGame", null, null)
	else:
		SceneSwitcher.switchScene( GameScn, [module, playerUnits] )


func deleteGame():
	Utility.setFreeing( m_game )
	m_game = null


# called by Game scene
func connectGame( game ):
	m_game == game
	Network.connect("allPlayersReady", game, "start")


func isGameInProgress():
	return m_game != null


func showAcceptDialog( message, title ):
	var dialog = AcceptDialog.new()
	dialog.set_title( title )
	dialog.set_text( message )
	dialog.set_name( title )
	dialog.connect("confirmed", dialog, "queue_free")
	get_tree().get_root().add_child(dialog)
	dialog.popup_centered_minsize()
	dialog.show()

