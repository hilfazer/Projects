extends Control

const LoadGameDialogScn      = preload("res://core/gui/LoadGameDialog.tscn")
const SaveGameDialogScn      = preload("res://core/gui/SaveGameDialog.tscn")
const GameSceneGd            = preload("./GameScene.gd")

var _game : GameSceneGd                setget setGame


signal resumed()
signal fileSelected()
signal quitRequested()


func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		pass


func onResumePressed():
	emit_signal("resumed")


func onQuitPressed():
	emit_signal("quitRequested")


func onSavePressed():
	var dialog = SaveGameDialogScn.instance()
	assert( not has_node( dialog.get_name() ) )
	dialog.connect("file_selected", _game, "saveGame")
	dialog.connect("file_selected", self, "onFileSelected")
	self.add_child(dialog)
	dialog.popup()
	dialog.connect("hide", dialog, "queue_free")


func onLoadPressed():
	var dialog = LoadGameDialogScn.instance()
	assert( not has_node( dialog.get_name() ) )
	dialog.connect("file_selected", _game, "loadGame")
	dialog.connect("file_selected", self, "onFileSelected")
	self.add_child(dialog)
	dialog.popup()
	dialog.connect("hide", dialog, "queue_free")


func onFileSelected( fileName ):
	emit_signal( "fileSelected" )


func setGame( game ):
	_game = game
