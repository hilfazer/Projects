extends Node

const MainMenuScn = "res://gui/MainMenu.tscn"
const DebugWindowScn = "res://debug/DebugWindow.tscn"
const LoadingScreenScn = "res://gui/LoadingScreen.tscn"
const GameSceneScn = "res://game/GameScene.tscn"

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


# called by MainMenu scene
func connectMainMenu( mainMenu ):
	m_mainMenu = mainMenu
	Network.connect("serverGameStatus", m_mainMenu, "getGameStatus")


func connectNewGameScene( newGameScene ):
	Network.connect("networkError",       newGameScene, "onNetworkError")
	Network.connect("playerListChanged",  newGameScene.get_node("Lobby"), "refreshLobby", [Network.m_players])
	Network.connect("playerJoined",       newGameScene.get_node("Lobby"), "sendToClient")
	newGameScene.connect("readyForGame",   self, "createGame")


func connectDebugWindow( debugWindow ):
	m_debugWindow = debugWindow
	Utility.connect("sendVariable", debugWindow, "updateVariable")


remote func createGame( module_, playerUnits ):
	SceneSwitcher.switchScene( LoadingScreenScn )

	if Network.isServer():
		rpc("createGame", null, null)
		SceneSwitcher.switchScene( GameSceneScn, [module_, playerUnits] )
	else:
		SceneSwitcher.switchScene( GameSceneScn, [null, null] )


func onGameEnded():
	assert( m_game )
	m_game = null
	SceneSwitcher.switchScene( MainMenuScn )


# called by Game scene
func connectGame( game ):
	assert( m_game == null )
	m_game = game

	game.connect("gameEnded", self, "onGameEnded")
	game.connect("gameEnded", Network, "endConnection")
	Network.connect("allPlayersReady", game, "start")
	

func loadGame( filePath ):
	if not isGameInProgress():
		return # TODO: create game

	m_game.load( filePath )


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
	dialog.raise()
