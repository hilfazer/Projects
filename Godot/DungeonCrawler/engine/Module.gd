# This script operates on module data that does not change
extends Reference

const CommonItemsDatabasePath= "res://data/common/items/CommonItemDatabase.gd"
const ItemDbFactoryGd        = preload("res://engine/items/ItemDbFactory.gd")
const ModuleDataGd           = preload("res://engine/ModuleData.gd")

const CommonModuleDir        = "res://data/common"
const UnitsSubdir            = "units"
const LevelsSubdir           = "levels"
const AssetsSubdir           = "assets"


var _data : ModuleDataGd
var _moduleFilename : String
var _itemDatabase : ItemDbBase


# checks if script has all required properties
static func verify( moduleData: ModuleDataGd ):
	var k : bool = true
	k = k && moduleData.get("itemDatabase")
	return k


func _init( moduleData: ModuleDataGd, moduleFilename: String ):
	_data = moduleData
	assert( moduleFilename and not moduleFilename.empty() )
	_moduleFilename = moduleFilename

#TODO rewrite
#	ItemDbFactoryGd.createItemDb(CommonItemsDatabasePath)
#	var errors = _itemDatabase.initialize()
#	for error in errors:
#		Debug.warn(self, error)
#	errors = moduleData.itemDatabase.initialize()
#	for error in errors:
#		Debug.warn(self, error)
#
#	var duplicates = ItemDbBase.checkForDuplictates( \
#		_itemDatabase, moduleData.itemDatabase )
#	if duplicates.size() > 0:
#		var message := "Databases %s and %s have duplicated IDs: " \
#			% [ _itemDatabase.get_script().resource_path
#				, moduleData.itemDatabase.get_script().resource_path
#				]
#		Debug.warn( self, message + str(duplicates) )


func getPlayerUnitMax() -> int:
	return _data.UnitMax


func getUnitsForCreation() -> Array:
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
		Debug.error( self, "Module: no file for level with name %s" % levelName )

	return fileName


func getUnitFilename( unitName : String ) -> String:
	if not _data.Units.has(unitName):
		Debug.info( self, "Module: no unit named %s" % unitName )
		return ""

	var fileName = _getFilename( unitName, UnitsSubdir )
	if fileName.empty():
		Debug.error( self, "Module: no file for unit with name %s" % unitName )

	return fileName


func getTargetLevelFilenameAndEntrance( sourceLevelName : String, entrance : String ) -> PoolStringArray:
	assert( _data.LevelNames.has(sourceLevelName) )
	if not _data.LevelConnections.has( [sourceLevelName, entrance] ):
		return PoolStringArray()

	var name_entrance : PoolStringArray = _data.LevelConnections[[sourceLevelName, entrance]]

	return PoolStringArray([ getLevelFilename( name_entrance[0] ), name_entrance[1] ])


func _getFilename( name : String, subdirectory : String ):
	assert( not name.is_abs_path() and name.get_extension().empty() )

	var fileName = name + Globals.SCENE_EXTENSION
	var fullName = _moduleFilename.get_base_dir() + "/" + subdirectory + "/" + fileName
	var file = File.new()
	if file.file_exists( fullName ):
		return fullName
	else:
		fullName = CommonModuleDir + "/" + subdirectory + "/" + fileName
		return fullName if file.file_exists( fullName ) else ""

