extends Node

const GameScenePath          = "res://core/game/GameScene.tscn"
const MainMenuPath           = "res://core/gui/MainMenuScene.tscn"
const GameSceneGd            = preload("./game/GameScene.gd")
const NewGameSceneGd         = preload("res://core/gui/NewGameScene.gd")
const MainMenuSceneGd        = preload("res://core/gui/MainMenuScene.gd")

var _game : GameSceneGd                setget _setGame


signal newGameSceneConnected( node )


func deleted(_a):
	assert(false)


func _init():
	set_pause_mode( PAUSE_MODE_PROCESS )
	name = get_script().resource_path.get_basename().get_file()


func _ready():
	SceneSwitcher.connect( "sceneSetAsCurrent", self, "_connectNewCurrentScene" )


func _connectNewCurrentScene():
	var newCurrent = get_tree().current_scene

	if newCurrent is NewGameSceneGd:
		newCurrent.connect( "readyForGame",  self, "_createGame", [], CONNECT_ONESHOT )
		newCurrent.connect( "finished",      self, "_toMainMenu", [], CONNECT_ONESHOT )

		emit_signal( "newGameSceneConnected", newCurrent )

	elif newCurrent is MainMenuSceneGd:
		newCurrent.connect( "saveFileSelected", self, "_loadGame", [], CONNECT_ONESHOT )


func _toMainMenu():
	SceneSwitcher.switchScene( MainMenuPath )


func _connectGame():
	assert( _game == null )
	var gameScene = get_tree().current_scene
	assert( gameScene is GameSceneGd )

	_setGame( gameScene )


func _createGame( module_, playerUnitsCreationData : Array ):
	SceneSwitcher.connect( "sceneSetAsCurrent", self, "_connectGame", [], CONNECT_ONESHOT )
	SceneSwitcher.switchScene( GameScenePath,
		{
			GameSceneGd.Params.Module : module_,
			GameSceneGd.Params.PlayerUnitsData : playerUnitsCreationData,
		} )


func onGameEnded():
	assert( _game )
	_toMainMenu()
	_setGame( null )


func _setGame( gameScene : GameSceneGd ):
	assert( gameScene == null or _game == null )
	_game = gameScene

	if gameScene:
		gameScene.connect( "gameFinished", self, "onGameEnded", [], CONNECT_ONESHOT )


func _loadGame( filePath ):
	if not isGameInProgress():
		SceneSwitcher.switchScene( GameScenePath, null )
		yield( SceneSwitcher, "sceneSetAsCurrent" )
		_connectGame()
		yield( get_tree().current_scene, "readyCompleted" )
	else:
		yield( _game.get_tree(), "idle_frame" )

	_game.loadGame( filePath )


func isGameInProgress():
	return _game != null

