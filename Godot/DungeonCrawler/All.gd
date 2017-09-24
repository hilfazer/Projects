extends Node

const GameGd = preload("res://modules/Game.gd")

var m_game


func _ready():
	gamestate.m_levelParentNodePath = get_node("GameContainer").get_path()
	
	gamestate.connect("sendVariable",       $"Variables", "updateVariable")

	gamestate.connect("connectionFailed",   $"Connect", "onConnectionFailed")
	gamestate.connect("gameEnded",          $"Connect", "onGameEnded")
	gamestate.connect("gameError",          $"Connect", "onGameError")
	gamestate.connect("networkPeerChanged", $"Connect", "onNetworkPeerChanged")

	gamestate.connect("networkPeerChanged", $"Lobby", "onNetworkPeerChanged")
	gamestate.connect("playerListChanged",  $"Lobby", "refreshLobby", [gamestate.m_players])
	gamestate.connect("playerJoined",       $"Lobby", "sendToClient")

	$"Lobby".connect("readyForGame",        self, "createGame")


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
