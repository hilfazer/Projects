extends Reference


static func findFilesInDirectory( directoryPath : String, extensionFilter := "" ) -> PoolStringArray:
	assert( directoryPath )
	assert( extensionFilter == "" or extensionFilter.get_extension() != "" )

	var filePaths := PoolStringArray()
	var dir = Directory.new()
	var error = dir.open( directoryPath )
	if error != OK:
		return PoolStringArray()

	dir.list_dir_begin( true )

	var file : String = dir.get_next()
	while file != "":
		if dir.current_is_dir():
			var subdirFilePaths := findFilesInDirectory( \
					dir.get_current_dir().plus_file( file ), extensionFilter )
			filePaths.append_array( subdirFilePaths )

		else:
			assert( dir.file_exists( file ) )
			if !extensionFilter or  "." + file.get_extension() == extensionFilter:
				filePaths.append( dir.get_current_dir().plus_file( file ) )

		file = dir.get_next()

	dir.list_dir_end()

	return filePaths

