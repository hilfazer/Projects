extends Control


func _ready():
	set_process_unhandled_key_input(false)
	Connector.connectDebugWindow( self )


func _input(event):
	if event.is_action_pressed("toggle_debug_window"):
		set_visible(not is_visible()) 
		accept_event()


func updateVariable(varName, value, addValue = false):
	get_node("Variables").updateVariable(varName, value, addValue)


func onVisibilityChanged():
	if is_visible():
		raise()
