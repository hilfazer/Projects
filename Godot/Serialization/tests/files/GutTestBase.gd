extends "res://addons/gut/test.gd"

const EPSILON = 0.00001
const FILES_DIR = "user://"

var _resourceExtension := ".tres" if OS.has_feature("debug") else ".res"
var _orphanCount : int
var _filesAtStart := []


func _init():
	assert( Directory.new().dir_exists( FILES_DIR ) )


func before_each():
	assert( _filesAtStart.empty() )
	_orphanCount = int( Performance.get_monitor( Performance.OBJECT_ORPHAN_NODE_COUNT ) )

	_filesAtStart = _findFilesInDirectory( FILES_DIR )


func after_each():
	for child in get_children():
		child.free()
	assert( get_child_count() == 0 )

	assert_eq( _orphanCount, Performance.get_monitor( Performance.OBJECT_ORPHAN_NODE_COUNT ), \
			"No new orphan nodes" )

	var fileDeleter = Directory.new()
	var filesNow : Array = _findFilesInDirectory( FILES_DIR )
	for filePath in filesNow:
		if not filePath in _filesAtStart:
			gut.file_delete( filePath )
	_filesAtStart.resize( 0 )


func _createDefaultTestFilePath( extension : String ) -> String:
	return FILES_DIR.plus_file( gut.get_current_test_object().name ) \
		+ ( "." + extension if extension else "" )


static func _findFilesInDirectory( directoryPath : String ) -> Array:
	assert( directoryPath )

	var filePaths := []

	var dir = Directory.new()
	dir.open( directoryPath )
	dir.list_dir_begin( true )

	var file : String = dir.get_next()
	while file != "":
		if dir.current_is_dir():
			var subdirFilePaths : Array = _findFilesInDirectory( \
					dir.get_current_dir().plus_file( file) )
			filePaths += subdirFilePaths

		else:
			assert( dir.file_exists( file ) )
			filePaths.append( dir.get_current_dir().plus_file( file ) )

		file = dir.get_next()

	dir.list_dir_end()

	return filePaths
