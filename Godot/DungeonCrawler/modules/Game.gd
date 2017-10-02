extends Node

const NodeName = "Game"
const CurrentLevelName = "CurrentLevel"
enum UnitFields {PATH = 0, OWNER = 1}

var m_levelLoader = preload("res://levels/LevelLoader.gd").new()
var m_module


signal gameStarted
signal gameEnded


func _init(module):
	assert( module )
	set_name(NodeName)
	m_module = module

func _enter_tree():
	Connector.connectGame( self )
	setPaused(true)
	
func _exit_tree():
	setPaused(false)

func delete():
	m_levelLoader.unloadLevel( self.get_node(CurrentLevelName) )
	m_module.free()

func setPaused( enabled ):
	get_tree().set_pause(enabled)

func loadStartingLevel():
	m_levelLoader.loadLevel( m_module.getStartingMap(), self, CurrentLevelName )
	emit_signal("gameStarted")

func placePlayerUnits( units ):
	m_levelLoader.insertPlayerUnits( units, self.get_node(CurrentLevelName) )
