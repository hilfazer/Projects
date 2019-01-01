extends Node

const DebugWindowScn         = preload("res://debug/DebugWindow.tscn")
const UtilityGd              = preload("res://Utility.gd")

var m_logLevel : int = 3               setget setLogLevel
var m_debugWindow : Control            setget deleted
var m_variables = {}                   setget deleted
var m_createGameDelay : float = 0


signal variableUpdated( varName, value )


func deleted(_a):
	assert(false)


func _input( event : InputEvent ):
	if event.is_action_pressed("toggle_debug_window"):
		if is_instance_valid( m_debugWindow ):
			UtilityGd.setFreeing( m_debugWindow )
			m_debugWindow = null
		else:
			_createDebugWindow()


func info( caller : Object, message : String ):
	if m_logLevel >= 3:
		print( message )


func warn( caller : Object, message : String ):
	if m_logLevel >= 2:
		push_warning( message )


func err( caller : Object, message : String ):
	if m_logLevel >= 1:
		push_error( message )


func setLogLevel( level : int ):
	m_logLevel = level


func updateVariable( varName : String, value, addValue = false ):
	if value == null:
		m_variables.erase(varName)
	elif addValue == true and m_variables.has(varName):
		m_variables[varName] += value
	else:
		m_variables[varName] = value
	emit_signal( "variableUpdated", varName, value )


func _createDebugWindow():
	var debugWindow = DebugWindowScn.instance()
	connect( "variableUpdated", debugWindow.get_node("Variables"), "updateVariable" )
	debugWindow.get_node("Variables").setVariables( m_variables )
	$"/root".add_child( debugWindow )
	m_debugWindow = debugWindow

