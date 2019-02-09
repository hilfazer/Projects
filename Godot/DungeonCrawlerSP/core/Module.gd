# This script operates on module data that does not change

extends Reference


const CommonModuleDir = "res://data/common"
const UnitsSubdir     = "units"
const LevelsSubdir    = "levels"
const AssetsSubdir    = "assets"
const SceneExtension  = "tscn"


var m_data                             setget deleted
var m_moduleFilename : String          setget deleted


func deleted(_a):
	assert(false)


# checks if script has all required properties
static func verify( moduleData ):
	return moduleData.get("UnitMax") \
		&& moduleData.get("Units") \
		&& moduleData.get("LevelNames") \
		&& moduleData.get("LevelConnections") \
		&& moduleData.get("StartingLevelName") \
		&& moduleData.get("DefaultLevelEntrances") \
		&& moduleData.get("LevelNames").has( moduleData.get("StartingLevelName") ) \
		&& moduleData.get("DefaultLevelEntrances").has( moduleData.get("StartingLevelName") )


func _init( moduleData, moduleFilename : String ):
	m_data = moduleData
	assert( moduleFilename and not moduleFilename.empty() )
	m_moduleFilename = moduleFilename


func getPlayerUnitMax() -> int:
	return m_data.UnitMax


func getUnitsForCreation():
	return m_data.Units


func getStartingLevelName() -> String:
	return m_data.StartingLevelName


func getLevelEntrance( levelName : String ) -> String:
	if levelName in m_data.DefaultLevelEntrances:
		return m_data.DefaultLevelEntrances[levelName]
	else:
		return ""


func getLevelFilename( levelName : String ) -> String:
	assert( not levelName.is_abs_path() and levelName.get_extension().empty() )
	if not m_data.LevelNames.has(levelName):
		Debug.info( self, "Module: no level named %s" % levelName )
		return ""

	var fileName = _getFilename( levelName, LevelsSubdir )
	if fileName.empty():
		Debug.err( self, "Module: no file for level with name %s" % levelName )

	return fileName


func getUnitFilename( unitName : String ) -> String:
	if not m_data.Units.has(unitName):
		Debug.info( self, "Module: no unit named %s" % unitName )
		return ""

	var fileName = _getFilename( unitName, UnitsSubdir )
	if fileName.empty():
		Debug.err( self, "Module: no file for unit with name %s" % unitName )

	return fileName


func getTargetLevelFilenameAndEntrance( sourceLevelName, entrance ) -> Array:
	assert( m_data.LevelNames.has(sourceLevelName) )
	if not m_data.LevelConnections.has( [sourceLevelName, entrance] ):
		return []

	var name_entrance = m_data.LevelConnections[[sourceLevelName, entrance]]

	return [ getLevelFilename( name_entrance[0] ), name_entrance[1] ]


func _getFilename( name : String, subdirectory : String ):
	assert( not name.is_abs_path() and name.get_extension().empty() )

	var fileName = name + '.' + SceneExtension
	var fullName = m_moduleFilename.get_base_dir() + "/" + subdirectory + "/" + fileName
	var file = File.new()
	if file.file_exists( fullName ):
		return fullName
	else:
		fullName = CommonModuleDir + "/" + subdirectory + "/" + fileName
		return fullName if file.file_exists( fullName ) else ""

