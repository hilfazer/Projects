extends Node

const MainMenuScn            = "res://gui/MainMenu.tscn"
const DebugWindowScn         = "res://debug/DebugWindow.tscn"
const LoadingScreenScn       = "res://gui/LoadingScreen.tscn"
const GameSceneScn           = "res://game/GameScene.tscn"
const GameSceneGd            = preload("res://game/GameScene.gd")
const AcceptDialogGd         = preload("res://gui/AcceptDialog.gd")

var m_game                             setget deleted
var m_debugWindow                      setget deleted


signal newGameSceneConnected( node )


func deleted(a):
	assert(false)


func _init():
	set_pause_mode(PAUSE_MODE_PROCESS)


func _ready():
	Network.connect("networkError", self, "onNetworkError")
	call_deferred("createDebugWindow")


func createDebugWindow():
	get_tree().get_root().add_child( preload(DebugWindowScn).instance() )


# called by MainMenu scene
func connectMainMenu( mainMenu ):
	Network.endConnection()
	Network.connect("serverGameStatus", mainMenu, "receiveGameStatus")


func connectNewGameScene( newGameScene ):
	Network.connect("networkError",       newGameScene, "onNetworkError")
	Network.connect("clientListChanged",  newGameScene.get_node("Lobby"), "refreshLobby", [Network.m_clients])

	newGameScene.connect("readyForGame",  self, "createGame")
	newGameScene.connect("finished",      self, "backToMainMenu")
	
	emit_signal( "newGameSceneConnected", newGameScene )
	
	
func backToMainMenu():
	SceneSwitcher.switchScene( MainMenuScn )


func connectDebugWindow( debugWindow ):
	m_debugWindow = debugWindow


func updateVariable(name, value, addValue = false):
	if m_debugWindow:
		m_debugWindow.updateVariable(name, value, addValue)


remote func createGame( module_, playerUnits, requestGameState = false ):
	SceneSwitcher.switchScene( LoadingScreenScn )

	if Network.isServer():
		rpc("createGame", null, null)

	SceneSwitcher.switchScene( GameSceneScn,
		{
			GameSceneGd.Module : module_,
			GameSceneGd.PlayerUnitsData : playerUnits,
			GameSceneGd.PlayersIds : Network.getOtherClientsIds(),
			GameSceneGd.RequestGameState : requestGameState
		} )


# called by Game scene
func connectGame( game ):
	assert( m_game == null )
	
	m_game = game
	game.connect("tree_exited", self, "resetGame")
	game.connect("gameEnded", self, "onGameEnded")


func onGameEnded():
	assert( m_game )
	
	SceneSwitcher.switchScene( MainMenuScn )
	resetGame()


func resetGame():
	m_game = null


func loadGame( filePath ):
	if not isGameInProgress():
		SceneSwitcher.switchScene( GameSceneScn, {GameSceneGd.SavedGame : filePath} )
	else:
		m_game.loadGame( filePath )


func isGameInProgress():
	return m_game != null


func onNetworkError( errorMessage ):
	if errorMessage == Network.ServerDisconnectedError:
		backToMainMenu()
	AcceptDialogGd.new().showAcceptDialog( \
		errorMessage, "Connection error", get_tree().get_root() )

