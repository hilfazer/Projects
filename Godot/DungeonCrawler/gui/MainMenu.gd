extends Node


func _ready():
	Connector.connectMainMenu(self)


func onSaveFileSelected( path ):
	pass


func onSaveDialogVisibilityChanged():
	pass


func onDialogVisibilityChanged( dialog ):
	get_node("GameContainer").visible = not dialog.is_visible()
	
