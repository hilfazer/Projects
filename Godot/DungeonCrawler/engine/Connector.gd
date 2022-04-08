extends Node

const GameScenePath          = "res://engine/game/GameScene.tscn"
const MainMenuPath           = "res://engine/gui/MainMenuScene.tscn"
const GameSceneGd            = preload("./game/GameScene.gd")
const NewGameSceneGd         = preload("res://engine/gui/NewGameScene.gd")
const MainMenuSceneGd        = preload("res://engine/gui/MainMenuScene.gd")

var _game : GameSceneGd                setget _setGame


signal newGameSceneConnected( node )


func deleted(_a):
	assert(false)


func _init():
	set_pause_mode( PAUSE_MODE_PROCESS )
	name = get_script().resource_path.get_basename().get_file()


func _ready():
# warning-ignore:return_value_discarded
	SceneSwitcher.connect( "scene_set_as_current", self, "_connectNewCurrentScene" )


func _connectNewCurrentScene():
	var newCurrent = get_tree().current_scene

	if newCurrent is NewGameSceneGd:
		newCurrent.connect( "readyForGame",  self, "_createGame", [], CONNECT_ONESHOT )
		newCurrent.connect( "finished",      self, "_toMainMenu", [], CONNECT_ONESHOT )

		emit_signal( "newGameSceneConnected", newCurrent )

	elif newCurrent is MainMenuSceneGd:
		newCurrent.connect( "saveFileSelected", self, "_loadGame", [], CONNECT_ONESHOT )

	elif newCurrent is GameSceneGd:
		assert( _game == null )
		_setGame( get_tree().current_scene )
# warning-ignore:return_value_discarded
		_game.connect( "gameFinished", self, "onGameEnded", [], CONNECT_ONESHOT )
# warning-ignore:return_value_discarded
		_game.connect( "nonmatchingSaveFileSelected", self, "_makeGameFromFile", [], CONNECT_ONESHOT )


func _toMainMenu():
	SceneSwitcher.switch_scene( MainMenuPath )


func _createGame( module_, playerUnitsCreationData : Array ):
	SceneSwitcher.switch_scene( GameScenePath,
		{
			GameSceneGd.Params.Module : module_,
			GameSceneGd.Params.PlayerUnitsData : playerUnitsCreationData,
		},
		GameSceneGd.PARAMS_META )


func onGameEnded():
	assert( _game )
	_toMainMenu()
	_setGame( null )


func _setGame( gameScene : GameSceneGd ):
	assert( gameScene == null or _game == null )
	_game = gameScene


func _loadGame( filePath : String ):
	assert(not _isGameInProgress())

	SceneSwitcher.switch_scene( GameScenePath,
		{ GameSceneGd.Params.SaveFileName : filePath }, GameSceneGd.PARAMS_META )


func _isGameInProgress() -> bool:
	return _game != null \
		&& not get_tree().current_scene is GameSceneGd


func _makeGameFromFile( filePath : String ):
	_setGame( null )

	SceneSwitcher.switch_scene( GameScenePath,
		{ GameSceneGd.Params.SaveFileName : filePath }, GameSceneGd.PARAMS_META )
