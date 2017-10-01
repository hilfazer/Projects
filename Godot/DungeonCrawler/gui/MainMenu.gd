extends Node



func _ready():
	Connector.connectMainMenu(self)


func onSaveFileSelected( path ):
	if (gamestate.isGameInProgress() == false):
		return

	gamestate.saveGame(path)


func onSaveDialogVisibilityChanged():
	gamestate.setPaused(get_node("SaveGameDialog/FileDialog").is_visible())
	
	
func onDialogVisibilityChanged( dialog ):
	get_node("GameContainer").visible = not dialog.is_visible()
	
