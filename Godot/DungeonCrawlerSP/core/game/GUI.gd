extends CanvasLayer

const GameMenuScn            = preload("GameMenu.tscn")

var _gameMenu
onready var _game                      = get_parent()


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
	gameMenu.setGame( get_parent() )
	gameMenu.connect( "resumed", self, "deleteGameMenu" )
	gameMenu.connect( "fileSelected", self, "deleteGameMenu" )
	gameMenu.connect( "quitRequested", _game, "finish" )
	_gameMenu = gameMenu


func deleteGameMenu():
	assert( _gameMenu != null )
	_gameMenu.queue_free()
	_gameMenu = null
