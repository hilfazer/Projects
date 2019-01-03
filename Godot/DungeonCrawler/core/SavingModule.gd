extends "./Module.gd"

const LevelBaseGd            = preload("./level/LevelBase.gd")
const SerializerGd           = preload("./Serializer.gd")
const SelfFilename           = "res://core/SavingModule.gd"

# JSON keys
const NameModule             = "Module"
const NameCurrentLevel       = "CurrentLevel"
const NamePlayerUnitsPaths   = "PlayerUnitsPaths"


var m_serializer = SerializerGd.new()  setget deleted


func deleted(_a):
	assert(false)


func _init( moduleData, moduleFilename : String, serializer = null ).( moduleData, moduleFilename ):
	if serializer:
		m_serializer = serializer
	else:
		m_serializer.add( [NameModule, moduleFilename] )
		m_serializer.add( [NameCurrentLevel, getStartingLevelName()] )


func saveToFile( saveFilename : String ) -> int:
	assert( m_serializer.getValue(NameModule) == m_moduleFilename )

	var result = m_serializer.saveToFile( saveFilename )
	if result != OK:
		Debug.warn( self, "SavingModule: could not save to file %s" % saveFilename )

	return result


func loadFromFile( saveFilename : String ):
	assert( moduleMatches( saveFilename ) )

	m_serializer.loadFromFile( saveFilename )


func saveLevel( level : LevelBaseGd, makeCurrent = true ):
	if not m_data.LevelNamesToFilenames.has( level.name ):
		Debug.warn( self,"SavingModule: module has no level named %s" % level.name)
		return

	var results = SerializerGd.serializeTest( level )
	if results.canSave() == false:
		Debug.warn( self,"SavingModule: level can't be serialized")
		return

	m_serializer.add( SerializerGd.serialize( level ) )

	if makeCurrent:
		m_serializer.add( [NameCurrentLevel, level.name] )


func loadLevelState( levelName : String, makeCurrent = true ):
	if not m_data.LevelNamesToFilenames.has( levelName ):
		Debug.warn( self,"SavingModule: module has no level named %s" % levelName)
		return null

	var state = m_serializer.getValue( levelName )

	if makeCurrent:
		m_serializer.add( [NameCurrentLevel, levelName] )

	return state


func savePlayerUnits( playerUnitsPaths ):
	m_serializer.add( [NamePlayerUnitsPaths, playerUnitsPaths] )


func moduleMatches( saveFilename : String ) -> bool:
	return extractModuleFilename( saveFilename ) == m_moduleFilename


func getCurrentLevelName() -> String:
	assert( m_serializer.getValue(NameCurrentLevel) )
	return m_serializer.getValue( NameCurrentLevel )


func getPlayerUnitsPaths() -> PoolStringArray:
	var paths = m_serializer.getValue(NamePlayerUnitsPaths)
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

