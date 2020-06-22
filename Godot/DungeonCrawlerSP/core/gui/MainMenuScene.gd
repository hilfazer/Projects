extends Control

const NewGameScnPath         = "res://core/gui/NewGameScene.tscn"
const LoadGameDialogScn      = preload("res://core/gui/LoadGameDialog.tscn")


signal saveFileSelected( filepath )


func newGame():
	SceneSwitcher.switchScene(NewGameScnPath)


func loadGame():
	var dialog = LoadGameDialogScn.instance()
	assert( not has_node( dialog.get_name() ) )
	dialog.connect ("file_selected", self, "onSaveFileSelected" )
	self.add_child (dialog )
	dialog.popup()
	dialog.connect( "hide", dialog, "queue_free" )


func exitProgram():
	get_tree().quit()


func onSaveFileSelected( filepath : String ):
	emit_signal( "saveFileSelected", filepath )
