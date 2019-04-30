extends "./LoggerBase.gd"


var _file : File


func _init( filename : String ):
	var logFile = File.new()
	var directory = Directory.new()
	if not directory.dir_exists( filename.get_base_dir() ):
		directory.make_dir_recursive( filename.get_base_dir() )

	var openResult = logFile.open(filename, File.WRITE)

	assert( openResult == OK )
	_file = logFile


func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		_file.close()


func info( caller : Object, message : String ):
	if _logLevel >= 3:
		_file.store_line( "INFO | %s" % [message] )


func warn( caller : Object, message : String ):
	if _logLevel >= 2:
		_file.store_line( "WARN | %s" % [message] )


func err( caller : Object, message : String ):
	if _logLevel >= 1:
		_file.store_line( "ERROR| %s" % [message] )
