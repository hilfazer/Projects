extends Node

var m_logLevel : int = 3               setget setLogLevel

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func info(caller, message):
	if m_logLevel >= 3:
		pass
	
	
func warn(caller, message):
	if m_logLevel >= 2:
		pass
	
	
func err(caller, message):
	if m_logLevel >= 1:
		pass
	

func setLogLevel( level : int ):
	m_logLevel = level
