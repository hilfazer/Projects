extends Node	#TODO: change to Reference if possible

var m_data                             setget deleted
var m_existingPlayerUnits = []         setget deleted


func deleted(a):
	assert(false)


static func verify( moduleData ):
	return moduleData.get("UnitMax") && moduleData.get("Units") && \
		moduleData.get("LevelNamesToFilenames") && moduleData.get("LevelConnections")


func _init( moduleData ):
	m_data = moduleData
	var pl = m_data.get_property_list()
	var p = m_data.get("LevelNamesToFilenames")
	var q = m_data.get("bah")
	pass


func getPlayerUnitMax():
	return m_data.UnitMax


func getUnitsForCreation():
	return m_data.Units


func getStartingLevelFilenameAndEntrance():
	return [ m_data.LevelNamesToFilenames["Level1"], "Entrance" ]


func getLevelFilename( levelName ):
	assert( m_data.LevelNamesToFilenames.has(levelName) )
	return m_data.LevelNamesToFilenames[levelName]


func getTargetLevelFilenameAndEntrance( sourceLevelName, entrance ):
	assert( m_data.LevelNamesToFilenames.has(sourceLevelName) )
	if not m_data.LevelConnections.has( [sourceLevelName, entrance] ):
		return null

	var name_entrance = m_data.LevelConnections[[sourceLevelName, entrance]]

	return [ getLevelFilename( name_entrance[0] ), name_entrance[1] ]


func getExistingPlayerUnits():
	return m_existingPlayerUnits


