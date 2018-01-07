extends Node

const GameSceneScn = "res://game/GameScene.tscn"
const LevelLoaderGd = preload("res://levels/LevelLoader.gd")
const PlayerAgentGd = preload("res://actors/PlayerAgent.gd")

const NodeName = "Game"
const CurrentLevelName = "CurrentLevel"
enum UnitFields {PATH = 0, OWNER = 1, NODE = 2}

var m_levelLoader = LevelLoaderGd.new()  setget deleted
var m_module                          setget deleted
var m_playerUnitsCreationData = []    setget deleted
var m_playerUnits = []                setget deleted


signal gameStarted
signal gameEnded


func deleted():
	assert(false)


func _init(module_ = null, playerUnitsData = null):
	assert( module_ != null == Network.isServer() )
	assert( playerUnitsData != null == Network.isServer() )
	set_name(NodeName)
	m_module = module_
	m_playerUnitsCreationData = playerUnitsData


func _enter_tree():
	Connector.connectGame( self )
	setPaused(true)
	if is_network_master():
		prepare()


func _exit_tree():
	setPaused(false)
	emit_signal("gameEnded")


func _input(event):
	if event.is_action_pressed("ui_select"):
		changeLevel()


func setPaused( enabled ):
	get_tree().set_pause(enabled)
	Utility.emit_signal("sendVariable", "Pause", "Yes" if enabled else "No")


func prepare():
	assert( Network.isServer() )

	m_playerUnits = createPlayerUnits( m_playerUnitsCreationData )
	m_levelLoader.loadLevel( m_module.getStartingLevel(), self, CurrentLevelName )
	m_levelLoader.insertPlayerUnits( m_playerUnits, self.get_node(CurrentLevelName) )

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

	assignAgentsToPlayerUnits( m_playerUnits )


slave func loadLevel(filename, nodePath, name):
	m_levelLoader.loadLevel(filename, get_tree().get_root().get_node(nodePath), name)
	Network.rpc_id( get_network_master(), "readyToStart", get_tree().get_network_unique_id() )


remote func start():
	if is_network_master():
		rpc("start")

	setPaused(false)
	emit_signal("gameStarted")
	SceneSwitcher.switchScene( GameSceneScn )


func finish():
	self.queue_free()


func createPlayerUnits( unitsCreationData ):
	var playerUnits = []
	for unitData in unitsCreationData:
		var unitNode_ = load( unitData["path"] ).instance()
		unitNode_.set_name( str(unitData["owner"]) )
		unitNode_.setNameLabel( Network.m_players[unitData["owner"]] )
		playerUnits.append( {OWNER : unitData["owner"], NODE : unitNode_} )

	return playerUnits


func assignAgentsToPlayerUnits( playerUnits ):
	assert( is_network_master() )

	for unit in playerUnits:
		var ow = unit[OWNER]
		if unit[OWNER] == get_tree().get_network_unique_id():
			assignOwnAgent( unit[NODE].get_path() )
		else:
			rpc_id( unit[OWNER], "assignOwnAgent", unit[NODE].get_path() )


remote func assignOwnAgent( unitNodePath ):
	var unitNode = get_node( unitNodePath )
	assert( unitNode )
	var playerAgent = Node.new()
	playerAgent.set_network_master( get_tree().get_network_unique_id() )
	playerAgent.set_script( PlayerAgentGd )
	playerAgent.setActions( PlayerAgentGd.PlayersActions[0] )
	playerAgent.assignToUnit( unitNode )


func changeLevel():
	var nextLevelPath = m_module.getNextLevel()
	if nextLevelPath == null:
		return

	var currentLevel = get_node(CurrentLevelName)
	if currentLevel == null:
		return

	for playerUnit in m_playerUnits:
		# leaving nodes without parent
		playerUnit[NODE].get_parent().remove_child( playerUnit[NODE] )

	Utility.setFreeing( currentLevel )
	currentLevel = null

	m_levelLoader.loadLevel( nextLevelPath, self, CurrentLevelName )
	m_levelLoader.insertPlayerUnits( m_playerUnits, self.get_node(CurrentLevelName) )

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
