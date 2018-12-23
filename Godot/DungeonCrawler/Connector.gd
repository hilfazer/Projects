extends Node

const GameScenePath          = "res://game/GameScene.tscn"
const MainMenuPath           = "res://gui/MainMenuScene.tscn"
const GameSceneGd            = preload("res://game/GameScene.gd")
const AcceptDialogGd         = preload("res://gui/AcceptDialog.gd")

var m_game                             setget setGame


signal newGameSceneConnected( node )


func deleted(_a):
	assert(false)


func _init():
	set_pause_mode(PAUSE_MODE_PROCESS)
	print( "-----\nSTART\n-----" )


func _ready():
	Network.connect("networkError", self, "onNetworkError")


# called by MainMenu scene
func connectMainMenu( mainMenu ):
	Network.endConnection()
	Network.connect("serverGameStatus", mainMenu, "receiveGameStatus")


func backToMainMenu():
	SceneSwitcher.switchScene( MainMenuPath )


func connectNewGameScene( newGameScene ):
	Network.connect("networkError",       newGameScene, "onNetworkError")
	Network.connect("clientListChanged",  newGameScene.get_node("Lobby"), "refreshLobby")

	newGameScene.connect("readyForGame",  self, "createGame")
	newGameScene.connect("finished",      self, "backToMainMenu")
	
	emit_signal( "newGameSceneConnected", newGameScene )


remote func createGame( module_, playerUnits, requestGameState = false ):
	if Network.isServer():
		rpc("createGame", null, null, true)

	SceneSwitcher.connect( "currentSceneChanged", self, "connectGame", [], CONNECT_ONESHOT )
	SceneSwitcher.switchScene( GameScenePath,
		{
			GameSceneGd.Params.Module : module_,
			GameSceneGd.Params.PlayerUnitsData : playerUnits,
			GameSceneGd.Params.PlayersIds : Network.getOtherClientsIds(),
			GameSceneGd.Params.RequestGameState : requestGameState
		} )


func connectGame():
	assert( m_game == null )
	var gameScene = get_tree().current_scene
	assert( gameScene is GameSceneGd )
	
	setGame( gameScene )


func onGameEnded():
	assert( m_game )
	
	SceneSwitcher.switchScene( MainMenuPath )
	setGame( null )


func setGame( gameScene : GameSceneGd ):
	assert( gameScene == null or m_game == null )
	m_game = gameScene

	if gameScene:
		gameScene.connect( "gameFinished", self, "onGameEnded", [], CONNECT_ONESHOT )


func loadGame( filePath ):
	if not isGameInProgress():
		SceneSwitcher.switchScene( GameScenePath, {GameSceneGd.Params.SavedGame : filePath} )
	else:
		m_game.loadGame( filePath )


func isGameInProgress():
	return m_game != null
	
	
func connectPlayerManager( manager ):
	Network.connect( "clientListChanged", manager, "onClientListChanged" )


func onNetworkError( errorMessage ):
	if errorMessage == Network.ServerDisconnectedError:
		backToMainMenu()
	AcceptDialogGd.new().showAcceptDialog( \
		errorMessage, "Connection error", get_tree().get_root() )

