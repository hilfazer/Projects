extends Node

const dir = "res://data/common/items"


func _ready():
	var files = list_files_recursive(dir)
	print(files)


func list_files_in_directory(path):
	var files = []
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin()

	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with("."):
			files.append(file)

	dir.list_dir_end()

	return files


func list_files_recursive(path):
	var files = list_files_in_directory(path)

	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin()

	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with(".") and dir.dir_exists(file):
			files += list_files_in_directory( dir.get_current_dir()+'/'+file )


	dir.list_dir_end()
	return files
