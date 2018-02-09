extends Control

const LoadGameDialogScn = preload("res://game/serialization/LoadGameDialog.tscn")
const SaveGameDialogScn = preload("res://game/serialization/SaveGameDialog.tscn")

const SaveGameDirectory = "res://save"
const SaveFileExtension = "sav"


var m_gameSerializer


func initialize( serializer ):
	m_gameSerializer = serializer


func onResumePressed():
	get_parent().deleteGameMenu()


func onQuitPressed():
	get_parent().emit_signal("quitGameRequested")


func onSavePressed():
	assert( m_gameSerializer )
	var dialog = SaveGameDialogScn.instance()
	assert( not has_node( dialog.get_name() ) )
	dialog.connect("hide", dialog, "queue_free")
	dialog.connect("file_selected", m_gameSerializer, "serialize")
	self.add_child(dialog)
	dialog.show()


func onLoadPressed():
	assert( m_gameSerializer )
	var dialog = LoadGameDialogScn.instance()
	assert( not has_node( dialog.get_name() ) )
	dialog.connect("hide", get_parent(), "deleteGameMenu")
	dialog.connect("hide", dialog, "queue_free")
	dialog.connect("file_selected", m_gameSerializer, "deserialize")
	self.add_child(dialog)
	dialog.show()
