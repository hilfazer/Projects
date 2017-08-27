extends Node


func onSelectPressed():
	get_node("ChooseModuleDialog/FileDialog").show()


func onSavePressed():
	get_node("SaveGameDialog/FileDialog").show()


func onSaveFileSelected( path ):
	if (gamestate.isGameInProgress() == false):
		return
		
	# todo: save game


func onSaveDialogVisibilityChanged():
	gamestate.setPaused(get_node("SaveGameDialog/FileDialog").is_visible())
