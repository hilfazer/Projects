extends Node

const CurrentLevelName = "CurrentLevel"
enum UnitFields {PATH = 0, OWNER = 1}

var m_levelLoader = preload("res://levels/LevelLoader.gd").new()
var m_module


func _init(module):
	assert( module )
	m_module = module


func delete():
	m_levelLoader.unloadLevel( self.get_node(CurrentLevelName) )
	m_module.free()


func loadStartingLevel():
	m_levelLoader.loadLevel( m_module.getStartingMap(), self, CurrentLevelName )
	
	
func placePlayerUnits( units ):
	m_levelLoader.insertPlayerUnits( units, self.get_node(CurrentLevelName) )
