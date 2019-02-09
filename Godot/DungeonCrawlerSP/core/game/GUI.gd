extends CanvasLayer

const GameMenuScn            = preload("GameMenu.tscn")

var m_gameMenu
onready var m_game                     = get_parent()


func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		toggleGameMenu()


func toggleGameMenu():
	if m_gameMenu == null:
		createGameMenu()
	else:
		deleteGameMenu()


func createGameMenu():
	assert( m_gameMenu == null )
	var gameMenu = GameMenuScn.instance()
	self.add_child( gameMenu )
	gameMenu.setGame( get_parent() )
	gameMenu.connect( "resumed", self, "deleteGameMenu" )
	gameMenu.connect( "fileSelected", self, "deleteGameMenu" )
	gameMenu.connect( "quitRequested", m_game, "finish" )
	m_gameMenu = gameMenu


func deleteGameMenu():
	assert( m_gameMenu != null )
	m_gameMenu.queue_free()
	m_gameMenu = null
