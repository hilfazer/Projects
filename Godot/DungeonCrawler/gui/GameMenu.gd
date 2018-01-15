extends Control


const SaveGameDirectory = "res://save"


func onResumePressed():
	get_parent().deleteGameMenu()


func onQuitPressed():
	get_parent().emit_signal("quitGameRequested")


func onSavePressed():
	get_node("SaveGameDialog").set_current_dir(SaveGameDirectory)
	get_node("SaveGameDialog").show()
