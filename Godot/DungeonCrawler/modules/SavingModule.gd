extends "res://modules/Module.gd"

const UtilityGd              = preload("res://Utility.gd")

const NameModule             = "Module"

var m_existingPlayerUnits = []         setget deleted
var m_moduleFilename = ""              setget deleted


func deleted(a):
	assert(false)


func _init( moduleData, moduleFilename : String ).( moduleData ):
	m_moduleFilename = moduleFilename


func saveToFile( saveFilename : String ):
	assert( moduleMatches( saveFilename ) )
	pass


func loadFromFile( saveFilename : String ):
	assert( moduleMatches( saveFilename ) )
	pass


func saveLevel( level : Node ):
	if not m_data.LevelNamesToFilenames.has( level.name ):
		UtilityGd.log("SavingModule: module has no level named " + level.name)
		return
	pass
	
	
func loadLevel( levelName : String ):
	if not m_data.LevelNamesToFilenames.has( levelName ):
		UtilityGd.log("SavingModule: module has no level named " + levelName)
		return
	pass
	
	
func moduleMatches( saveFilename : String ):
	var saveFile = File.new()
	if not OK == saveFile.open(saveFilename, File.READ):
		return false

	var gameStateDict = parse_json(saveFile.get_as_text())
	return gameStateDict[NameModule] == m_moduleFilename
	#TODO: cache files or make module filename quickly accessible
	
	