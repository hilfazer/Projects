extends Node


func _ready():
	gamestate.m_levelParentNodePath = get_node("ViewportContainer/Viewport").get_path()


func onSelectPressed():
	get_node("ChooseModuleDialog/FileDialog").show()


func onSavePressed():
	get_node("SaveGameDialog/FileDialog").show()


func onSaveFileSelected( path ):
	if (gamestate.isGameInProgress() == false):
		return

	gamestate.saveGame(path)


func onSaveDialogVisibilityChanged():
	gamestate.setPaused(get_node("SaveGameDialog/FileDialog").is_visible())
