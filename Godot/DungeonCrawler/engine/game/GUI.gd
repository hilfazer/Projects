extends CanvasLayer

const GameMenuScn            = preload("GameMenu.tscn")
const GameMenuGd             = preload("res://engine/game/GameMenu.gd")
const GameSceneGd            = preload("res://engine/game/GameScene.gd")

var _gameMenu : GameMenuGd
onready var _game : GameSceneGd        = get_parent()


func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		toggleGameMenu()


func toggleGameMenu():
	if _gameMenu == null:
		createGameMenu()
	else:
		deleteGameMenu()


func createGameMenu():
	assert( _gameMenu == null )
	var gameMenu = GameMenuScn.instance()
	self.add_child( gameMenu )
	gameMenu.connect( "visibility_changed", _game, "setPause", [gameMenu.visible] )
	gameMenu.connect( "tree_exiting", _game, "setPause", [false] )
	gameMenu.connect( "resumeSelected", self, "_resume" )
	gameMenu.connect( "saveSelected", self, "_saveGame" )
	gameMenu.connect( "loadSelected", self, "_loadGame" )
	gameMenu.connect( "quitSelected", self, "_quit" )
	_gameMenu = gameMenu


func deleteGameMenu():
	assert( _gameMenu != null )
	_gameMenu.queue_free()
	_gameMenu = null


func _resume():
	deleteGameMenu()


func _saveGame( filepath : String ):
	deleteGameMenu()
	_game.saveGame( filepath )


func _loadGame( filepath : String ):
	_gameMenu.disconnect( "tree_exiting", _game, "setPause" )
	deleteGameMenu()
	_game.loadGame( filepath )


func _quit():
	_gameMenu.disconnect( "tree_exiting", _game, "setPause" )
	_game.finish()
