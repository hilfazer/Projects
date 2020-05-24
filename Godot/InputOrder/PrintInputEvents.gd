extends Node

enum Handling {no, input, gui, unhandled}

export(bool) var _detectMouseClick = true
export(Handling) var _handleMouseClick = Handling.no

export(bool) var _detectKeys = true
export(Handling) var _handleKeys = Handling.no

export(bool) var _detectInput = true             setget _setDetectInput
export(bool) var _detectUnhandledInput = true    setget _setDetectUnhandledInput


func _ready():
	set_process_input( _detectInput )
	set_process_unhandled_input( _detectUnhandledInput )
	set_process_unhandled_key_input( _detectUnhandledInput )


func _input(event):
	if event is InputEventKey and _detectKeys:
		var doHandle = _handleKeys == Handling.input
		doHandle && get_tree().set_input_as_handled()
		printEvent( event, '_input', doHandle )
	elif event is InputEventMouseButton and _detectMouseClick:
		var doHandle = _handleMouseClick == Handling.input
		doHandle && get_tree().set_input_as_handled()
		printEvent( event, '_input', doHandle )


func _unhandled_input(event):
	if event is InputEventKey and _detectKeys:
		var doHandle = _handleKeys == Handling.unhandled
		doHandle && get_tree().set_input_as_handled()
		printEvent( event, '_unhandled_input', doHandle )
	elif event is InputEventMouseButton and _detectMouseClick:
		var doHandle = _handleMouseClick == Handling.unhandled
		doHandle && get_tree().set_input_as_handled()
		printEvent( event, '_unhandled_input', doHandle )


func _gui_input(event):
	if event is InputEventKey and _detectKeys:
		var doHandle = _handleKeys == Handling.gui
		doHandle && call("accept_event")
		printEvent( event, '_gui_input', doHandle )
	elif event is InputEventMouseButton and _detectMouseClick:
		var doHandle = _handleMouseClick == Handling.gui
		doHandle && call("accept_event")
		printEvent( event, '_gui_input', doHandle )


func printEvent( event : InputEvent, function : String, handled : bool ):
	if event.is_pressed() == false:
		return

	print( "%-40s %-25s %s \n\t\t %s"
		% [get_path(), function, "[HANDLED]" if handled else "", event.as_text()] )


func _setDetectInput( set ):
	_detectInput = set
	set_process_input( set )


func _setDetectUnhandledInput( set ):
	_detectUnhandledInput = set
	set_process_unhandled_input( set )
	set_process_unhandled_key_input( set )
