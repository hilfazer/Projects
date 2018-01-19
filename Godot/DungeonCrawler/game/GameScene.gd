extends Node

const GameMenuScn = "res://gui/GameMenu.tscn"
const GameGd = preload("res://game/Game.gd")

var m_gameMenu


signal quitGameRequested
signal saveToFileRequested( filename )


func _ready():
	var gameNode = get_tree().get_root().get_node( GameGd.NodeName )
	connect("quitGameRequested", gameNode, "finish")
	connect("saveToFileRequested", gameNode, "save")


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