extends Node

const DebugWindowScn         = preload("res://debug/DebugWindow.tscn")
const UtilityGd              = preload("res://core/Utility.gd")

var _logLevel := 3                     setget setLogLevel
var _debugWindow : CanvasLayer         setget deleted
var _variables := {}                   setget deleted


signal variableUpdated( varName, value )


func deleted(_a):
	assert(false)


func _init():
	set_pause_mode(PAUSE_MODE_PROCESS)


func _input( event : InputEvent ):
	if event.is_action_pressed("toggle_debug_window"):
		if is_instance_valid( _debugWindow ):
			UtilityGd.setFreeing( _debugWindow )
			_debugWindow = null
		else:
			_createDebugWindow()


func info( caller : Object, message : String ):
	if _logLevel >= 3:
		print( message )


func warn( caller : Object, message : String ):
	if _logLevel >= 2:
		push_warning( message )


func err( caller : Object, message : String ):
	if _logLevel >= 1:
		push_error( message )


func setLogLevel( level : int ):
	_logLevel = level


func updateVariable( varName : String, value, addValue = false ):
	if value == null:
		_variables.erase(varName)
	elif addValue == true and _variables.has(varName):
		_variables[varName] += value
	else:
		_variables[varName] = value
	emit_signal( "variableUpdated", varName, value )


func _createDebugWindow():
	assert( _debugWindow == null )
	var debugWindow = DebugWindowScn.instance()
	connect( "variableUpdated", debugWindow.get_node("Variables"), "updateVariable" )
	debugWindow.get_node("Variables").setVariables( _variables )
	$"/root".add_child( debugWindow )
	_debugWindow = debugWindow

