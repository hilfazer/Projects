extends Control


signal tryDelete


func _ready():
	Connector.connectMainMenu(self)


func _input(event):
	if event.is_action_pressed("ui_cancel"):
		emit_signal("tryDelete")
		accept_event()


func onSaveFileSelected( path ):
	pass


func onSaveDialogVisibilityChanged():
	pass


func onDialogVisibilityChanged( dialog ):
	get_node("GameContainer").visible = not dialog.is_visible()
	
