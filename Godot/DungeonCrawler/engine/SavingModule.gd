extends "./Module.gd"

const SerializerGd           = preload("res://projects/Serialization/HierarchicalSerializer.gd")
const ProbeGd                = preload("res://projects/Serialization/Probe.gd")
const SavedGameRes           = preload("res://projects/Serialization/SaveGameFile.gd")
const PlayerAgentGd          = preload("res://engine/agent/PlayerAgent.gd")
const SelfFilename           = "res://engine/SavingModule.gd"

# JSON keys
const NameModule             = "Module"
const NameCurrentLevel       = "CurrentLevel"
const NamePlayerData         = "PlayerData"


var _serializer : SerializerGd = SerializerGd.new()   setget deleted


func deleted(_a):
	assert(false)


func _init( moduleData, moduleFilename : String, serializer = null ) \
		.( moduleData, moduleFilename ):

	if serializer:
		_serializer = serializer
	else:
		_serializer.userData[NameModule] = moduleFilename
		_serializer.userData[NameCurrentLevel] = getStartingLevelName()


func saveToFile( saveFilename : String ) -> int:
	assert( _serializer.userData.get(NameModule) == _moduleFilename )

	var result = _serializer.saveToFile( saveFilename )
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
		var probe : ProbeGd.Probe = ProbeGd.scan( level )
		for node in probe.nodesNotInstantiable:
			Debug.warn( self, "noninstantiable node: %s" %
				[ node.get_script().resource_path ] )
		for node in probe.nodesNoMatchingDeserialize:
			Debug.warn( self, "node has no deserialize(): %s" %
				[ node.get_script().resource_path ] )

	_serializer.addAndSerialize( level.name, level )

	if makeCurrent:
		_serializer.userData[NameCurrentLevel] = level.name


func loadLevelState( levelName : String, makeCurrent = true ):
	if not _data.LevelNames.has( levelName ):
		Debug.warn( self,"SavingModule: module has no level named %s" % levelName)
		return null

	var state = null
	if _serializer.hasKey( levelName ):
		state = _serializer.getSerialized( levelName )

	if makeCurrent:
		_serializer.userData[NameCurrentLevel] = levelName

	return state


func savePlayerData( playerAgent : PlayerAgentGd ):
	var playerData = _serializer.serialize( playerAgent )
	_serializer.userData[NamePlayerData] = playerData


func moduleMatches( saveFilename : String ) -> bool:
	return extractModuleFilename( saveFilename ) == _moduleFilename


func getCurrentLevelName() -> String:
	assert( _serializer.userData.get( NameCurrentLevel ) )
	return _serializer.userData.get( NameCurrentLevel )


func getPlayerData():
	return _serializer.userData.get( NamePlayerData )


static func extractModuleFilename( saveFilename : String ) -> String:
	var saveFile = File.new()
	if not OK == saveFile.open( saveFilename, File.READ ):
		return ""

	var moduleFile := ""
	var state : SavedGameRes = ResourceLoader.load( saveFilename )
	if state.userDict.has(NameModule):
		moduleFile = state.userDict[NameModule]

	return moduleFile
	# TODO: cache files or make module filename quickly accessible


static func createFromSaveFile( saveFilename : String ):
	var serializer : SerializerGd = SerializerGd.new()
	var loadResult = serializer.loadFromFile( saveFilename )
	if loadResult != OK:
		Debug.warn( null,"SavingModule: could not create module from file %s" % saveFilename)
		return null

	var moduleFilename = serializer.userData.get(NameModule)
	var moduleNode = null

	var dataResource = load(moduleFilename)
	if dataResource:
		var moduleData: ModuleDataGd = load(moduleFilename).new()
		if verify( moduleData ):
			moduleNode = load(SelfFilename).new(moduleData, moduleFilename, serializer)

	return moduleNode

