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


func _init( moduleData, moduleFilename : String, serializer = null ).( moduleData, moduleFilename ):
	if serializer:
		m_serializer = serializer
	else:
		m_serializer.add( [NameModule, moduleFilename] )
		m_serializer.add( [NameCurrentLevel, getStartingLevelName()] )


func saveToFile( saveFilename : String ):
	assert( m_serializer.getValue(NameModule) == m_moduleFilename )
	
	var result = m_serializer.saveToFile( saveFilename )
	if result != OK:
		UtilityGd.log( "SavingModule: could not save to file %s" % saveFilename )

	return result == OK


func loadFromFile( saveFilename : String ):
	assert( moduleMatches( saveFilename ) )

	m_serializer.loadFromFile( saveFilename )


func saveLevel( level : LevelBaseGd, makeCurrent = true ):
	if not m_data.LevelNamesToFilenames.has( level.name ):
		UtilityGd.log("SavingModule: module has no level named " + level.name)
		return
		
	var results = SerializerGd.serializeTest( level )
	if results.canSave() == false:
		UtilityGd.log("SavingModule: level can't be serialized")
		return

	m_serializer.add( SerializerGd.serialize( level ) )

	if makeCurrent:
		m_serializer.add( [NameCurrentLevel, level.name] )


func loadLevelState( levelName : String, makeCurrent = true ):
	if not m_data.LevelNamesToFilenames.has( levelName ):
		UtilityGd.log("SavingModule: module has no level named " + levelName)
		return null

	var state = m_serializer.getValue( levelName )

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
	assert( m_serializer.getValue(NameCurrentLevel) )
	return m_serializer.getValue( NameCurrentLevel )


func getPlayerUnitsPaths() -> PoolStringArray:
	var paths = m_serializer.getValue(NamePlayerUnitsPaths)
	return paths if paths else PoolStringArray()


static func createFromSaveFile( saveFilename : String ):
	var serializer : SerializerGd = SerializerGd.new()
	var loadResult = serializer.loadFromFile( saveFilename )
	if loadResult != OK:
		UtilityGd.log("SavingModule: could not create module from file %s" % saveFilename)
		return null
		
	var moduleFilename = serializer.getValue(NameModule)
	var moduleNode = null
	

	var dataResource = load(moduleFilename)
	if dataResource:
		var moduleData = load(moduleFilename).new()
		if verify( moduleData ):
			moduleNode = load(SelfFilename).new(moduleData, moduleFilename, serializer)

	return moduleNode

