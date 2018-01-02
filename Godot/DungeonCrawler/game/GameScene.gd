extends Node

const GameMenuScn = "res://gui/GameMenu.tscn"

var m_gameMenu


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
	var gameMenu = preload( GameMenuScn ).instance()
	self.add_child( gameMenu )
	m_gameMenu = gameMenu


func deleteGameMenu():
	assert( m_gameMenu != null )
	m_gameMenu.queue_free()
	m_gameMenu = null