extends "./Module.gd"

const SerializerGd           = preload("res://core/HierarchicalSerializer.gd")
const SelfFilename           = "res://core/SavingModule.gd"

# JSON keys
const NameModule             = "Module"
const NameCurrentLevel       = "CurrentLevel"
const NamePlayerUnitsPaths   = "PlayerUnitsPaths"


var _serializer = SerializerGd.new()   setget deleted


func deleted(_a):
	assert(false)


func _init( moduleData, moduleFilename : String, serializer = null ).( moduleData, moduleFilename ):
	if serializer:
		_serializer = serializer
	else:
		_serializer.add( NameModule, moduleFilename )
		_serializer.add( NameCurrentLevel, getStartingLevelName() )


func saveToFile( saveFilename : String ) -> int:
	assert( _serializer.getValue(NameModule) == _moduleFilename )

	var result = _serializer.saveToFile( saveFilename, true )
	if result != OK:
		Debug.warn( self, "SavingModule: could not save to file %s" % saveFilename )

	return result


func loadFromFile( saveFilename : String ):
	assert( moduleMatches( saveFilename ) )

	_serializer.loadFromFile( saveFilename )


func saveLevel( level : LevelBase, makeCurrent : bool ):
	if not _data.LevelNames.has( level.name ):
		Debug.warn( self,"SavingModule: module has no level named %s" % level.name)
		return

	if OS.has_feature("debug"):
		var results = SerializerGd.serializeTest( level )
		for node in results.getNotInstantiableNodes():
			Debug.warn( self, "noninstantiable node: %s" %
				[ node.get_script().resource_path ] )
		for node in results.getNodesNoMatchingDeserialize():
			Debug.warn( self, "node has no deserialize(): %s" %
				[ node.get_script().resource_path ] )

	_serializer.add( level.name, SerializerGd.serialize( level ) )

	if makeCurrent:
		_serializer.add( NameCurrentLevel, level.name )


func loadLevelState( levelName : String, makeCurrent = true ):
	if not _data.LevelNames.has( levelName ):
		Debug.warn( self,"SavingModule: module has no level named %s" % levelName)
		return null

	var state = _serializer.getValue( levelName ) if _serializer.hasKey( levelName ) else null

	if makeCurrent:
		_serializer.add( NameCurrentLevel, levelName )

	return state


func savePlayerUnitPaths( level : LevelBase, unitNodes : Array ):
	var relativeUnitPaths := []
	for node in unitNodes:
		assert( level.is_a_parent_of( node ) )
		relativeUnitPaths.append( level.get_path_to( node ) )
	_serializer.add( NamePlayerUnitsPaths, relativeUnitPaths )


func moduleMatches( saveFilename : String ) -> bool:
	return extractModuleFilename( saveFilename ) == _moduleFilename


func getCurrentLevelName() -> String:
	assert( _serializer.getValue( NameCurrentLevel ) )
	return _serializer.getValue( NameCurrentLevel )


# paths relative to current level's name
func getPlayerUnitsPaths() -> PoolStringArray:
	var paths = _serializer.getValue(NamePlayerUnitsPaths)
	return paths if paths else PoolStringArray()


static func extractModuleFilename( saveFilename : String ) -> String:
	var saveFile = File.new()
	if not OK == saveFile.open( saveFilename, File.READ ):
		return ""

	var gameStateDict = parse_json( saveFile.get_as_text() )
	return gameStateDict[NameModule]
	#TODO: cache files or make module filename quickly accessible


static func createFromSaveFile( saveFilename : String ):
	var serializer : SerializerGd = SerializerGd.new()
	var loadResult = serializer.loadFromFile( saveFilename )
	if loadResult != OK:
		Debug.warn( null,"SavingModule: could not create module from file %s" % saveFilename)
		return null

	var moduleFilename = serializer.getValue(NameModule)
	var moduleNode = null


	var dataResource = load(moduleFilename)
	if dataResource:
		var moduleData = load(moduleFilename).new()
		if verify( moduleData ):
			moduleNode = load(SelfFilename).new(moduleData, moduleFilename, serializer)

	return moduleNode

