extends "./LoggerBase.gd"


func info( caller : Object, message : String ):
	if _logLevel >= 3:
		print( message )


func warn( caller : Object, message : String ):
	if _logLevel >= 2:
		push_warning( message )
		print( message )


func error( caller : Object, message : String ):
	if _logLevel >= 1:
		push_error( message )
		print( message )
