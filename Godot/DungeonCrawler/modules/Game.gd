extends Node

const NodeName = "Game"
const CurrentLevelName = "CurrentLevel"
enum UnitFields {PATH = 0, OWNER = 1}

var m_levelLoader = preload("res://levels/LevelLoader.gd").new()
var m_module
var m_playerUnits = []


signal gameStarted
signal gameEnded


func _init(module = null, playerUnits = null):
	assert( module != null == Network.isServer() )
	assert( playerUnits != null == Network.isServer() )
	set_name(NodeName)
	m_module = module
	m_playerUnits = playerUnits

func _enter_tree():
	Connector.connectGame( self )
	setPaused(true)
	if is_network_master():
		prepare()

func _exit_tree():
	setPaused(false)
	emit_signal("gameEnded")

func setPaused( enabled ):
	get_tree().set_pause(enabled)
	Network.emit_signal("sendVariable", "Pause", "Yes" if enabled else "No")

func prepare():
	assert( Network.isServer() )
	
	m_levelLoader.loadLevel( m_module.getStartingMap(), self, CurrentLevelName )
	m_levelLoader.insertPlayerUnits( m_playerUnits, self.get_node(CurrentLevelName) )
	m_playerUnits = []

	Network.readyToStart( get_tree().get_network_unique_id() )
	
	for playerId in Network.m_players:
		if playerId == Network.ServerId:
			continue
			
		rpc_id(
			playerId, 
			"loadLevel",
			get_node(CurrentLevelName).get_filename(),
			get_node(CurrentLevelName).get_parent().get_path(),
			get_node(CurrentLevelName).get_name()
			)
		get_node(CurrentLevelName).sendToClient(playerId)

slave func loadLevel(filename, nodePath, name):
	m_levelLoader.loadLevel(filename, get_tree().get_root().get_node(nodePath), name)
	Network.rpc_id( get_network_master(), "readyToStart", get_tree().get_network_unique_id() )

remote func start():
	if is_network_master():
		rpc("start")

	setPaused(false)
	emit_signal("gameStarted")