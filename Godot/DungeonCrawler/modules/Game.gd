extends Reference

const CurrentLevelName = "CurrentLevel"
enum UnitFields {PATH = 0, OWNER = 1}

var m_levelLoader = preload("res://levels/LevelLoader.gd").new()
var m_rootNode
var m_module


func _init(rootNode, module):
	assert( rootNode and module )
	m_rootNode = rootNode
	m_module = module


func loadStartingLevel():
	m_levelLoader.loadLevel( m_module.getStartingMap(), m_rootNode, CurrentLevelName )
	
	
func placePlayerUnits( units ):
	m_levelLoader.insertPlayerUnits( units, m_rootNode.get_node(CurrentLevelName) )
