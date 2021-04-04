extends Control

const LoadGameDialogScn      = preload("res://engine/gui/LoadGameDialog.tscn")
const SaveGameDialogScn      = preload("res://engine/gui/SaveGameDialog.tscn")


signal resumeSelected()
signal saveSelected( filepath )
signal loadSelected( filepath )
signal quitSelected()


func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		pass


func onResumePressed():
	emit_signal("resumeSelected")


func onQuitPressed():
	emit_signal("quitSelected")


func onSavePressed():
	var dialog = SaveGameDialogScn.instance()
	assert( not has_node( dialog.get_name() ) )
	dialog.connect("file_selected", self, "_onSaveFileSelected")
	self.add_child(dialog)
	dialog.popup()
	dialog.connect("hide", dialog, "queue_free")


func onLoadPressed():
	var dialog = LoadGameDialogScn.instance()
	assert( not has_node( dialog.get_name() ) )
	dialog.connect("file_selected", self, "_onLoadFileSelected")
	self.add_child(dialog)
	dialog.popup()
	dialog.connect("hide", dialog, "queue_free")


func _onSaveFileSelected( filePath ):
	emit_signal( "saveSelected", filePath )


func _onLoadFileSelected( filePath ):
	emit_signal( "loadSelected", filePath )
