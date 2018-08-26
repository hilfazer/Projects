extends "res://modules/Module.gd"

const UtilityGd              = preload("res://Utility.gd")
const LevelBaseGd            = preload("res://levels/LevelBase.gd")
const SerializerGd           = preload("./Serializer.gd")
const SelfFilename           = "res://modules/SavingModule.gd"

# JSON keys
const NameModule             = "Module"
const NameCurrentLevel       = "CurrentLevel"
const NamePlayerUnitsPaths   = "PlayerUnitsPaths"


var m_serializer = SerializerGd.new()  setget deleted


func deleted(a):
	assert(false)


func _init( moduleData, moduleFilename : String ).( moduleData, moduleFilename ):
	m_serializer.add( [NameModule, moduleFilename] )
	m_serializer.add( [NameCurrentLevel, getStartingLevelName()] )


func saveToFile( saveFilename : String ):
	var saveFile = File.new()

	if not OK == saveFile.open(saveFilename, File.WRITE):
		UtilityGd.log( "Serializer: could not open file %s" % saveFilename )
		return false

	assert( m_serializer.getValue(NameModule) == m_moduleFilename )

	saveFile.store_line( to_json( m_gameStateDict ) )
	saveFile.close()
	return true


func loadFromFile( saveFilename : String ):
	assert( moduleMatches( saveFilename ) )

	m_serializer.loadFromFile( saveFilename )


func saveLevel( level : LevelBaseGd, makeCurrent = true ):
	if not m_data.LevelNamesToFilenames.has( level.name ):
		UtilityGd.log("SavingModule: module has no level named " + level.name)
		return
		
	var results = SerializerGd.serializeTest( level )
	if results.canSave() == false:
		print("level can't be deserialized")
		return

	m_serializer.add( SerializerGd.serialize( level ) )

	if makeCurrent:
		m_serializer.add( [NameCurrentLevel, level.name] )


func loadLevelState( levelName : String, makeCurrent = true ):
	if not m_data.LevelNamesToFilenames.has( levelName ):
		UtilityGd.log("SavingModule: module has no level named " + levelName)
		return null

	var state = m_serializer.getValue( levelname )

	if makeCurrent:
		m_serializer.add( [NameCurrentLevel, levelName] )

	return state


func savePlayerUnits( playerUnitsPaths ):
	m_serializer.add( [NamePlayerUnitsPaths, playerUnitsPaths] )


func moduleMatches( saveFilename : String ):
	var saveFile = File.new()
	if not OK == saveFile.open(saveFilename, File.READ):
		return false

	var gameStateDict = parse_json(saveFile.get_as_text())
	return gameStateDict[NameModule] == m_moduleFilename
	#TODO: cache files or make module filename quickly accessible


func getCurrentLevelName() -> String:
	assert( not m_gameStateDict[NameCurrentLevel].empty() )
	return m_serializer.getValue( NameCurrentLevel )


func getPlayerUnitsPaths() -> PoolStringArray:
	var paths = m_serializer.getValue(NamePlayerUnitsPaths)
	return paths if paths else PoolStringArray()


static func createFromSaveFile( saveFilename : String ):
	var gameDict : Dictionary = _gameDictFromSaveFile( saveFilename )
	var moduleFilename = gameDict[NameModule]
	var moduleNode = null

	var dataResource = load(moduleFilename)
	if dataResource:
		var moduleData = load(moduleFilename).new()
		if verify( moduleData ):
			moduleNode = load(SelfFilename).new(moduleData, moduleFilename)

	if moduleNode:
		moduleNode.loadFromFile( saveFilename )
	return moduleNode


static func _gameDictFromSaveFile( saveFilename : String ) -> Dictionary:
	var saveFile = File.new()

	if not OK == saveFile.open(saveFilename, File.READ):
		UtilityGd.log( "Serializer: could not open file %s" % saveFilename )
		return _emptyGameState()

	var message = validate_json( saveFile.get_as_text() )
	if not message.empty():
		UtilityGd.log( message )
		return _emptyGameState()

	return parse_json( saveFile.get_as_text() )


static func _emptyGameState():
	return { NameModule : "", NameCurrentLevel : "", NamePlayerUnitsPaths : PoolStringArray() }



