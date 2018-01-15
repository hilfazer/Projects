extends Control


const SaveGameDirectory = "res://save"
const SaveFileExtension = "sav"


func onResumePressed():
	get_parent().deleteGameMenu()


func onQuitPressed():
	get_parent().emit_signal("quitGameRequested")


func onSavePressed():
	get_node("SaveGameDialog").set_current_dir(SaveGameDirectory)
	get_node("SaveGameDialog").show()


func saveToFile( filename ):
	var filenameWithExtension = filename
	if filenameWithExtension.get_extension() != SaveFileExtension:
		filenameWithExtension = filenameWithExtension + "." + SaveFileExtension

	get_parent().emit_signal("saveToFileRequested", filenameWithExtension)
