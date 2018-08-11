extends "res://modules/Module.gd"

const UtilityGd              = preload("res://Utility.gd")
const LevelBaseGd            = preload("res://levels/LevelBase.gd")
const SelfFilename           = "res://modules/SavingModule.gd"

# JSON names
const NameModule             = "Module"
const NameCurrentLevel       = "CurrentLevel"
const NamePlayerUnitsPaths   = "PlayerUnitsPaths"


var m_moduleFilename = ""              setget deleted
var m_gameStateDict = _emptyGameState()setget deleted


func deleted(a):
	assert(false)


func _init( moduleData, moduleFilename : String ).( moduleData ):
	m_moduleFilename = moduleFilename


func saveToFile( saveFilename : String ):
	assert( moduleMatches( saveFilename ) )
	pass


func loadFromFile( saveFilename : String ):
	assert( moduleMatches( saveFilename ) )
	
	m_gameStateDict = {}
	m_gameStateDict = _gameDictFromSaveFile( saveFilename )
	assert( not m_gameStateDict.empty() )


func saveLevel( level : LevelBaseGd ):
	if not m_data.LevelNamesToFilenames.has( level.name ):
		UtilityGd.log("SavingModule: module has no level named " + level.name)
		return

	if m_gameStateDict.has(level.name):
		m_gameStateDict[level.name] = {}

	m_gameStateDict[level.name] = level.serialize()


func loadLevelState( levelName : String, makeCurrent = true ):
	if not m_data.LevelNamesToFilenames.has( levelName ):
		UtilityGd.log("SavingModule: module has no level named " + levelName)
		return null

	var state = null
	if m_gameStateDict.has( levelName ):
		state = m_gameStateDict[levelName]
	
	if makeCurrent:
		m_gameStateDict[NameCurrentLevel] = getLevelFilename( levelName )

	return state
	
	
func moduleMatches( saveFilename : String ):
	var saveFile = File.new()
	if not OK == saveFile.open(saveFilename, File.READ):
		return false

	var gameStateDict = parse_json(saveFile.get_as_text())
	return gameStateDict[NameModule] == m_moduleFilename
	#TODO: cache files or make module filename quickly accessible
	
	
func getCurrentLevelName() -> String:
	if m_gameStateDict[NameCurrentLevel].empty():
		return getStartingLevelFilenameAndEntrance()[0]
	else:
		return m_gameStateDict[NameCurrentLevel]
	
	
static func createFromSaveFile( saveFilename : String ):
	var gameDict : Dictionary = _gameDictFromSaveFile( saveFilename )
	if gameDict.empty() or not gameDict.has(NameModule):
		return null
		
	var moduleFilename = gameDict[NameModule]
	var moduleNode = null

	var dataResource = load(moduleFilename)
	if dataResource:
		var moduleData = load(moduleFilename).new()
		if verify( moduleData ):
			moduleNode = load(SelfFilename).new(moduleData, moduleFilename)

	moduleNode.loadFromFile( saveFilename )
	return moduleNode
	

static func _gameDictFromSaveFile( saveFilename : String ) -> Dictionary:
	var saveFile = File.new()

	if not OK == saveFile.open(saveFilename, File.READ):
		UtilityGd.log( "Serializer: File %s" % saveFilename + " does not exist" )
		return {}

	var message = validate_json( saveFile.get_as_text() )
	if not message.empty():
		UtilityGd.log( message )
		return {}
	
	return parse_json( saveFile.get_as_text() )


static func _emptyGameState():
	return { NameModule : "", NameCurrentLevel : "", NamePlayerUnitsPaths = [] }



