extends Reference

var _logLevel := 2                     setget setLogLevel


func setLogLevel( level : int ):
	_logLevel = level


# warning-ignore:unused_argument
# warning-ignore:unused_argument
func info( caller : Object, message : String ):
	pass


# warning-ignore:unused_argument
# warning-ignore:unused_argument
func warn( caller : Object, message : String ):
	pass


# warning-ignore:unused_argument
# warning-ignore:unused_argument
func error( caller : Object, message : String ):
	pass
