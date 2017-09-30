extends Node

const GameGd = preload("res://modules/Game.gd")

var m_game


func _ready():
	gamestate.m_levelParentNodePath = get_node("GameContainer").get_path()

	$"Lobby".connect("readyForGame",        self, "createGame")
	$"Connect".connect("stopPressed",       self, "endGame")

	Connector.connectMainMenu(self)


func onSaveFileSelected( path ):
	if (gamestate.isGameInProgress() == false):
		return

	gamestate.saveGame(path)


func onSaveDialogVisibilityChanged():
	gamestate.setPaused(get_node("SaveGameDialog/FileDialog").is_visible())
	
	
func onDialogVisibilityChanged( dialog ):
	get_node("GameContainer").visible = not dialog.is_visible()
	
	
func createGame( module, playerUnits ):
	m_game = GameGd.new( get_node("GameContainer"), module )
	m_game.loadStartingLevel()
	m_game.placePlayerUnits(playerUnits)
	get_node("Lobby").hide()


func endGame():
	if m_game:
		m_game.delete()
		m_game = null

	get_node("Connect").onGameEnded()
	get_node("Lobby").show()
