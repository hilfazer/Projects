extends Control


const LoadGameDialogScn = preload("res://game/serialization/LoadGameDialog.tscn")

const SaveGameDirectory = "res://save"
const SaveFileExtension = "sav"


func onResumePressed():
	get_parent().deleteGameMenu()


func onQuitPressed():
	get_parent().emit_signal("quitGameRequested")


func onSavePressed():
	get_node("SaveGameDialog").set_current_dir(SaveGameDirectory)
	get_node("SaveGameDialog").show()


func saveToFile( filePath ):
	var filenameWithExtension = filePath
	if filenameWithExtension.get_extension() != SaveFileExtension:
		filenameWithExtension = filenameWithExtension + "." + SaveFileExtension

	get_parent().emit_signal("saveToFileRequested", filenameWithExtension)


func onLoadPressed():
	var dialog = LoadGameDialogScn.instance()
	assert( not has_node( dialog.get_name() ) )
	dialog.connect("hide", dialog, "queue_free")
	dialog.connect("file_selected", Connector, "loadGame")
	self.add_child(dialog)
	dialog.show()
