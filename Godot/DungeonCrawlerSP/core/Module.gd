# This script operates on module data that does not change

extends Reference


const CommonModuleDir = "res://data/common"
const UnitsSubdir     = "units"
const LevelsSubdir    = "levels"
const AssetsSubdir    = "assets"
const SceneExtension  = "tscn"


var _data                              setget deleted
var _moduleFilename : String           setget deleted


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
	_data = moduleData
	assert( moduleFilename and not moduleFilename.empty() )
	_moduleFilename = moduleFilename


func getPlayerUnitMax() -> int:
	return _data.UnitMax


func getUnitsForCreation():
	return _data.Units


func getStartingLevelName() -> String:
	return _data.StartingLevelName


func getLevelEntrance( levelName : String ) -> String:
	if levelName in _data.DefaultLevelEntrances:
		return _data.DefaultLevelEntrances[levelName]
	else:
		return ""


func getLevelFilename( levelName : String ) -> String:
	assert( not levelName.is_abs_path() and levelName.get_extension().empty() )
	if not _data.LevelNames.has(levelName):
		Debug.info( self, "Module: no level named %s" % levelName )
		return ""

	var fileName = _getFilename( levelName, LevelsSubdir )
	if fileName.empty():
		Debug.err( self, "Module: no file for level with name %s" % levelName )

	return fileName


func getUnitFilename( unitName : String ) -> String:
	if not _data.Units.has(unitName):
		Debug.info( self, "Module: no unit named %s" % unitName )
		return ""

	var fileName = _getFilename( unitName, UnitsSubdir )
	if fileName.empty():
		Debug.err( self, "Module: no file for unit with name %s" % unitName )

	return fileName


func getTargetLevelFilenameAndEntrance( sourceLevelName : String, entrance : String ) -> Array:
	assert( _data.LevelNames.has(sourceLevelName) )
	if not _data.LevelConnections.has( [sourceLevelName, entrance] ):
		return []

	var name_entrance = _data.LevelConnections[[sourceLevelName, entrance]]

	return [ getLevelFilename( name_entrance[0] ), name_entrance[1] ]


func _getFilename( name : String, subdirectory : String ):
	assert( not name.is_abs_path() and name.get_extension().empty() )

	var fileName = name + '.' + SceneExtension
	var fullName = _moduleFilename.get_base_dir() + "/" + subdirectory + "/" + fileName
	var file = File.new()
	if file.file_exists( fullName ):
		return fullName
	else:
		fullName = CommonModuleDir + "/" + subdirectory + "/" + fileName
		return fullName if file.file_exists( fullName ) else ""

