extends "./LoggerBase.gd"


func info( _caller : Object, message : String ):
	if _logLevel >= 3:
		print( message )


func warn( _caller : Object, message : String ):
	if _logLevel >= 2:
		push_warning( message )
		print( message )


func error( _caller : Object, message : String ):
	if _logLevel >= 1:
		push_error( message )
		print( message )
