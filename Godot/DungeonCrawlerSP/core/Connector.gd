extends Node

const GameScenePath          = "res://core/game/GameScene.tscn"
const MainMenuPath           = "res://core/gui/MainMenuScene.tscn"
const GameSceneGd            = preload("./game/GameScene.gd")
const AcceptDialogGd         = preload("./gui/AcceptDialog.gd")

var _game : GameSceneGd                setget setGame


signal newGameSceneConnected( node )


func deleted(_a):
	assert(false)


func _init():
	set_pause_mode( PAUSE_MODE_PROCESS )


func _ready():
	if OS.has_feature("debug"):
		Debug.setLogToConsole( true )
		Debug.setLogToFile( true )
		Debug.setLogLevel( 3 )


func toMainMenu():
	SceneSwitcher.switchScene( MainMenuPath )


func connectNewGameScene( newGameScene ):
	newGameScene.connect("readyForGame",  self, "createGame")
	newGameScene.connect("finished",      self, "toMainMenu")

	emit_signal( "newGameSceneConnected", newGameScene )


remote func createGame( module_, playerUnitsCreationData : Array ):
	SceneSwitcher.connect( "sceneSetAsCurrent", self, "connectGame", [], CONNECT_ONESHOT )
	SceneSwitcher.switchScene( GameScenePath,
		{
			GameSceneGd.Params.Module : module_,
			GameSceneGd.Params.PlayerUnitsData : playerUnitsCreationData,
		} )


func connectGame():
	assert( _game == null )
	var gameScene = get_tree().current_scene
	assert( gameScene is GameSceneGd )

	setGame( gameScene )


func onGameEnded():
	assert( _game )
	toMainMenu()
	setGame( null )


func setGame( gameScene : GameSceneGd ):
	assert( gameScene == null or _game == null )
	_game = gameScene

	if gameScene:
		gameScene.connect( "gameFinished", self, "onGameEnded", [], CONNECT_ONESHOT )


func loadGame( filePath ):
	if not isGameInProgress():
		SceneSwitcher.switchScene( GameScenePath, null )
		yield( SceneSwitcher, "sceneSetAsCurrent" )
		connectGame()
		yield( get_tree().current_scene, "readyCompleted" )
	else:
		yield( _game.get_tree(), "idle_frame" )

	_game.loadGame( filePath )


func isGameInProgress():
	return _game != null

