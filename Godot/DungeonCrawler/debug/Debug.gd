extends Node

const DebugWindowScn         = preload("res://debug/DebugWindow.tscn")
const LoggerBaseGd           = preload("res://debug/LoggerBase.gd")
const ConsoleLoggerGd        = preload("res://debug/ConsoleLogger.gd")
const FileLoggerGd           = preload("res://debug/FileLogger.gd")

const LogFilename = "res://ignored/logfile.log"

var _debugWindow : CanvasLayer         setget deleted
var _variables := {}                   setget deleted
var _loggers := []                     setget deleted
var _consoleLogger : ConsoleLoggerGd   setget deleted
var _fileLogger : FileLoggerGd         setget deleted

export var performPrints := false


signal variableUpdated( varName, value )


func deleted(_a):
	assert(false)


func _init():
	set_pause_mode(PAUSE_MODE_PROCESS)

	if OS.has_feature("debug"):
		_repositionWindow()


func _input( event : InputEvent ):
	if event.is_action_pressed("toggle_debug_window"):
		if is_instance_valid( _debugWindow ):
			Utility.setFreeing( _debugWindow )
			_debugWindow = null
		else:
			_createDebugWindow()


func info( caller : Object, message : String ):
	for logger in _loggers:
		logger.info( caller, message )


func warn( caller : Object, message : String ):
	for logger in _loggers:
		logger.warn( caller, message )


func error( caller : Object, message : String ):
	for logger in _loggers:
		logger.error( caller, message )


func setLogLevel( level : int ):
	for logger in _loggers:
		logger.setLogLevel( level )


func setLogToConsole( doLog : bool ):
	if doLog and _consoleLogger == null:
		_consoleLogger = ConsoleLoggerGd.new()
		addLogger( _consoleLogger )
	elif not doLog and _consoleLogger != null:
		removeLogger( _consoleLogger )
		_consoleLogger = null


func setLogToFile( doLog : bool ):
	if doLog and _fileLogger == null:
		_fileLogger = FileLoggerGd.new( LogFilename )
		addLogger( _fileLogger )
	elif not doLog and _fileLogger != null:
		removeLogger( _fileLogger )
		_fileLogger = null


func addLogger( logger : LoggerBaseGd ):
	if not logger in _loggers:
		_loggers.append( logger )


func removeLogger( logger : LoggerBaseGd ):
	assert( logger in _loggers )
	_loggers.remove( _loggers.find( logger) )


func updateVariable( varName : String, value, addValue := false ):
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
# warning-ignore:return_value_discarded
	connect( "variableUpdated", debugWindow.get_node("Variables"), "updateVariable" )
	debugWindow.get_node("Variables").setVariables( _variables )
	$"/root".add_child( debugWindow )
	_debugWindow = debugWindow


func _repositionWindow():
	var screen_size = OS.get_screen_size(0)
	var window_size = OS.get_window_size()
	OS.set_window_position( (screen_size*0.38 - window_size*0.4) )
