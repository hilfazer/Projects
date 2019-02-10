extends Control

const NewGameScnPath         = "res://core/gui/NewGameScene.tscn"
const LoadGameDialogScn      = preload("res://core/gui/LoadGameDialog.tscn")

func newGame():
	var params = {}
	params["playerName"] = get_node("PlayerData/Name").text

	SceneSwitcher.switchScene(NewGameScnPath, params)


func loadGame():
	var dialog = LoadGameDialogScn.instance()
	assert( not has_node( dialog.get_name() ) )
	dialog.connect ("file_selected", Connector, "loadGame" )
	self.add_child (dialog )
	dialog.popup()
	dialog.connect( "hide", dialog, "queue_free" )


func exitProgram():
	get_tree().quit()
