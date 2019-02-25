extends Node

export(bool) var _detectMouseClick = true
export(bool) var _handleMouseClick = false
export(bool) var _detectKeys = true
export(bool) var _handleKeys = false

export(bool) var _detectInput = true             setget _setDetectInput
export(bool) var _detectUnhandledInput = true    setget _setDetectUnhandledInput


func _ready():
	set_process_input( _detectInput )
	set_process_unhandled_input( _detectUnhandledInput )
	set_process_unhandled_key_input( _detectUnhandledInput )


func _input(event):
	if event is InputEventKey and _detectKeys:
		printEvent( event, '_input' )
		if _handleKeys:
			get_tree().set_input_as_handled()
	elif event is InputEventMouseButton and _detectMouseClick:
		printEvent( event, '_input' )
		if _handleMouseClick:
			get_tree().set_input_as_handled()


func _unhandled_input(event):
	if event is InputEventKey and _detectKeys:
		printEvent( event, '_unhandled_input' )
		if _handleKeys:
			get_tree().set_input_as_handled()
	elif event is InputEventMouseButton and _detectMouseClick:
		printEvent( event, '_unhandled_input' )
		if _handleMouseClick:
			get_tree().set_input_as_handled()


func _gui_input(event):
	if event is InputEventKey and _detectKeys:
		printEvent( event, '_gui_input' )
		if _handleKeys:
			call("accept_event")
	elif event is InputEventMouseButton and _detectMouseClick:
		printEvent( event, '_gui_input' )
		if _handleMouseClick:
			call("accept_event")


func printEvent( event : InputEvent, function : String ):
	print( "%-40s %-30s %s \n\t\t %s"
		% [get_path(), function, get_class(), event.as_text()] )


func _setDetectInput( set ):
	_detectInput = set
	set_process_input( set )


func _setDetectUnhandledInput( set ):
	_detectUnhandledInput = set
	set_process_unhandled_input( set )
	set_process_unhandled_key_input( set )