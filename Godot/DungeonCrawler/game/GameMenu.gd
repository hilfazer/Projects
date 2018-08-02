extends Control

const LoadGameDialogScn      = preload("./serialization/LoadGameDialog.tscn")
const SaveGameDialogScn      = preload("./serialization/SaveGameDialog.tscn")
const LiveGameLobbyScn       = preload("res://gui/lobby/LiveGameLobby.tscn")


func _unhandled_input(event):
	if not event.is_action("ui_cancel"):
		get_tree().set_input_as_handled()


func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		pass


func onResumePressed():
	get_parent().deleteGameMenu()


func onQuitPressed():
	get_parent().emit_signal("quitGameRequested")


func onSavePressed():
	var dialog = SaveGameDialogScn.instance()
	assert( not has_node( dialog.get_name() ) )
	dialog.connect("hide", dialog, "queue_free")
	dialog.connect("file_selected", get_parent(), "saveGame")
	self.add_child(dialog)
	dialog.popup()


func onLoadPressed():
	var dialog = LoadGameDialogScn.instance()
	assert( not has_node( dialog.get_name() ) )
	dialog.connect("hide", dialog, "queue_free")
	dialog.connect("file_selected", get_parent(), "loadGame")
	self.add_child(dialog)
	dialog.popup()


func onLobbyPressed():
	var lobby = LiveGameLobbyScn.instance()
	get_parent().add_child( lobby )
