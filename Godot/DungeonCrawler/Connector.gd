extends Node

const MainMenuScn = "res://gui/MainMenu.tscn"
const GameGd = preload("res://modules/Game.gd")

var m_mainMenu setget deleted, deleted
var m_game     setget deleted, deleted


func deleted():
	assert(false)


func _init():
	set_pause_mode(PAUSE_MODE_PROCESS)


func _ready():
	Network.connect("networkError", self, "showAcceptDialog", ["Connection error"])


func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		createMainMenu()


func createMainMenu():
	deleteMainMenu()
	var mainMenu = preload(MainMenuScn).instance()
	get_tree().get_root().add_child( mainMenu )


func deleteMainMenu():
	Utility.setFreeing( m_mainMenu )
	m_mainMenu = null


func tryDeleteMainMenu():
	if isGameInProgress():
		deleteMainMenu()


# called by MainMenu scene
func connectMainMenu( mainMenu ):
	m_mainMenu = mainMenu

	Utility.connect("sendVariable",     mainMenu.get_node("Variables"), "updateVariable")
	connectMainMenuToGame( m_mainMenu, m_game )


func connectMainMenuToGame( mainMenu, game ):
	if !mainMenu or !game:
		return


remote func createGame( module, playerUnits ):
	if Network.isServer():
		rpc("createGame", null, null)
		m_game = GameGd.new( module, playerUnits )
		get_tree().get_root().add_child( m_game )
	else:
		m_game = GameGd.new()
		get_tree().get_root().add_child( m_game )


func deleteGame():
	Utility.setFreeing( m_game )
	m_game = null


# called by Game scene
func connectGame( game ):
	assert( m_game == game )

	Network.connect("allPlayersReady", game, "start")
	game.connect("gameStarted", self, "deleteMainMenu")
	connectMainMenuToGame( m_mainMenu, m_game )


func isGameInProgress():
	return m_game != null


func showAcceptDialog( message, title ):
	var dialog = AcceptDialog.new()
	dialog.set_title( title )
	dialog.set_text( message )
	dialog.set_name( title )
	dialog.connect("confirmed", dialog, "queue_free")
	get_tree().get_root().add_child(dialog)
	dialog.popup_centered_minsize()
	dialog.show()

