extends Reference

var _logLevel := 2                     setget setLogLevel


func setLogLevel( level : int ):
	_logLevel = level


func info( caller : Object, message : String ):
	pass


func warn( caller : Object, message : String ):
	pass


func err( caller : Object, message : String ):
	pass
