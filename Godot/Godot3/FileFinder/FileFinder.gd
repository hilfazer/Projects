extends Reference


static func findFilesInDirectory( directoryPath : String ) -> PoolStringArray:
	assert( directoryPath )

	var filePaths := PoolStringArray()

	var dir = Directory.new()
	dir.open( directoryPath )
	dir.list_dir_begin( true )

	var file : String = dir.get_next()
	while file != "":
		if dir.current_is_dir():
			var subdirFilePaths := findFilesInDirectory( \
					dir.get_current_dir().plus_file( file) )
			filePaths.append_array( subdirFilePaths )

		else:
			assert( dir.file_exists( file ) )
			filePaths.append( dir.get_current_dir().plus_file( file ) )

		file = dir.get_next()

	dir.list_dir_end()

	return filePaths

