# This script operates on module data that does not change

extends Reference

const CommonModuleDir = "res://data/common"
const UnitsSubdir     = "units"
const LevelsSubdir    = "levels"
const AssetsSubdir    = "assets"

var m_data                             setget deleted
var m_moduleFilename : String          setget deleted


func deleted(_a):
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
	var a = moduleFilename.get_file()
	var b = moduleFilename.get_basename()
	var c = moduleFilename.get_base_dir()
	pass


func getPlayerUnitMax():
	return m_data.UnitMax


func getUnitsForCreation():
	return m_data.Units


func getStartingLevelName():
	return m_data.StartingLevelName


func getStartingLevelFilenameAndEntrance():
	return [  getLevelFilename( getStartingLevelName() ),
		m_data.StartingLevelEntrance ]


func getLevelFilename( levelName : String ):
	assert( m_data.LevelNamesToFilenames.has(levelName) )
	var fileName = m_data.LevelNamesToFilenames[levelName]
	var fullName = _selfBaseDir() + "/" + LevelsSubdir + "/" + fileName
	var file = File.new()
	if file.file_exists( fullName ):
		return fullName
	else:
		fullName = CommonModuleDir + "/" + LevelsSubdir + "/" + fileName
		if file.file_exists( fullName ):
			return fullName
		else:
			Debug.err( self, "Module: no file for level with name %s" % levelName )
			return ""


func getTargetLevelFilenameAndEntrance( sourceLevelName, entrance ):
	assert( m_data.LevelNamesToFilenames.has(sourceLevelName) )
	if not m_data.LevelConnections.has( [sourceLevelName, entrance] ):
		return null

	var name_entrance = m_data.LevelConnections[[sourceLevelName, entrance]]

	return [ getLevelFilename( name_entrance[0] ), name_entrance[1] ]


func _selfBaseDir():
	return m_moduleFilename.get_base_dir()



