extends Node


func _ready():
	gamestate.m_levelParentNodePath = get_node("LevelContainer").get_path()
	gamestate.connect("sendVariable", $"Variables", "updateVariable")
	gamestate.connect("playerListChanged", $"Lobby", "refreshLobby", [gamestate.m_players])

	gamestate.connect("connectionFailed", $"Connect", "onConnectionFailed")
	gamestate.connect("gameEnded", $"Connect", "onGameEnded")
	gamestate.connect("gameError", $"Connect", "onGameError")
	gamestate.connect("networkPeerChanged", $"Connect", "onNetworkPeerChanged")
	gamestate.connect("networkPeerChanged", $"Lobby", "onNetworkPeerChanged")


func onSaveFileSelected( path ):
	if (gamestate.isGameInProgress() == false):
		return

	gamestate.saveGame(path)


func onSaveDialogVisibilityChanged():
	gamestate.setPaused(get_node("SaveGameDialog/FileDialog").is_visible())
	
	
func onDialogVisibilityChanged( dialog ):
	get_node("LevelContainer").visible = not dialog.is_visible()
