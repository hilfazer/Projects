extends Reference

const NodeGuardGd            = preload("./NodeGuard.gd")
const SerializedStateGd      = preload("./SerializedState.gd")

var _version : String = ProjectSettings.get_setting("application/config/version")
var _nodesData := {}

var userData := {}
var resourceExtension := ".tres" if OS.has_feature("debug") else ".res"


func add( key : String, value ) -> void:
	_nodesData[ key ] = value


func remove( key : String ) -> bool:
	return _nodesData.erase( key )


func hasKey( key : String ) -> bool:
	return _nodesData.has( key )


func getValue( key : String ):
	return _nodesData[key]


func getKeys() -> Array:
	return _nodesData.keys()


func getVersion() -> String:
	return _version


func saveToFile( filepath : String ) -> int:
	var baseDirectory = filepath.get_base_dir()

	if not filepath.is_valid_filename() and baseDirectory.empty():
		print("not a valid filepath")
		return ERR_CANT_CREATE

	var dir := Directory.new()
	if not dir.dir_exists( baseDirectory ):
		var error = dir.make_dir_recursive( baseDirectory )
		if error != OK:
			print( "could not create a directory" )
			return error

	var stateToSave = SerializedStateGd.new()
	_version = ProjectSettings.get_setting("application/config/version")
	if _version != "":
		stateToSave.version = _version

	stateToSave.nodesDict = _nodesData
	stateToSave.userDict = userData

	var pathToSave = filepath
	if not filepath.get_extension() in ResourceSaver.get_recognized_extensions(stateToSave):
		pathToSave += resourceExtension

	var error := ResourceSaver.save( pathToSave, stateToSave )
	if error != OK:
		print( "could not save a Resource" )
		return error

	return OK



func loadFromFile( filepath : String ) -> int:
	var file := File.new()
	if not file.file_exists( filepath ):
		print( "files does not exist" )
		return ERR_DOES_NOT_EXIST

	var loadedState : SerializedStateGd = load( filepath )
	_version = loadedState.version
	_nodesData = loadedState.nodesDict
	userData = loadedState.userDict
	return OK
