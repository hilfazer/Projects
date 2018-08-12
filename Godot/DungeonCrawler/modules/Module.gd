# This script operates on module data that does not change

extends Node	#TODO: change to Reference if possible

var m_data                             setget deleted
var m_moduleFilename : String          setget deleted


func deleted(a):
	assert(false)


# checks if script has all required properties
static func verify( moduleData ):
	return moduleData.get("UnitMax") \
		&& moduleData.get("Units") \
		&& moduleData.get("LevelNamesToFilenames") \
		&& moduleData.get("LevelConnections") \
		&& moduleData.get("StartingLevelName") \
		&& moduleData.get("StartingLevelEntrance") \
		&& moduleData.get("LevelNamesToFilenames").has( moduleData.get("StartingLevelName") )


func _init( moduleData, moduleFilename : String ):
	m_data = moduleData
	assert( moduleFilename and not moduleFilename.empty() )
	m_moduleFilename = moduleFilename


func getPlayerUnitMax():
	return m_data.UnitMax


func getUnitsForCreation():
	return m_data.Units


func getStartingLevelName():
	return m_data.StartingLevelName


func getStartingLevelFilenameAndEntrance():
	return [ m_data.LevelNamesToFilenames[getStartingLevelName()], m_data.StartingLevelEntrance ]


func getLevelFilename( levelName ):
	assert( m_data.LevelNamesToFilenames.has(levelName) )
	return m_data.LevelNamesToFilenames[levelName]


func getTargetLevelFilenameAndEntrance( sourceLevelName, entrance ):
	assert( m_data.LevelNamesToFilenames.has(sourceLevelName) )
	if not m_data.LevelConnections.has( [sourceLevelName, entrance] ):
		return null

	var name_entrance = m_data.LevelConnections[[sourceLevelName, entrance]]

	return [ getLevelFilename( name_entrance[0] ), name_entrance[1] ]

