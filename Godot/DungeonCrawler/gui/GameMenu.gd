extends Control


func onResumePressed():
	get_parent().deleteGameMenu()


func onQuitPressed():
	get_parent().emit_signal("quitGameRequested")
