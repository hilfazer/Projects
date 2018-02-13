extends Node

const GameMenuScn = "res://game/GameMenu.tscn"
const GameSerializerGd = preload("./serialization/GameSerializer.gd")
const PlayerAgentGd = preload("res://actors/PlayerAgent.gd")
const LevelLoaderGd = preload("res://levels/LevelLoader.gd")

enum UnitFields { OWNER, NODE, WEAKREF }
enum Params { Module, PlayerUnitsData, SavedGame }

var m_module_                         setget deleted
var m_playerUnitsCreationData = []    setget deleted
var m_playerUnits = []                setget deleted
var m_currentLevel                    setget setCurrentLevel
var m_gameMenu                        setget deleted
var m_playersWithGameScene = []       setget deleted
var m_serializer = GameSerializerGd.new(self)   setget deleted

signal gameStarted
signal gameEnded
signal quitGameRequested


func deleted():
	assert(false)


func _enter_tree():
	var params = SceneSwitcher.getParams()
	
	if params.has(Module):
		m_module_ = params[Module]
		assert( m_module_ != null == Network.isServer() or params.has(SavedGame) )

	if params.has(PlayerUnitsData):
		m_playerUnitsCreationData = params[PlayerUnitsData]
		assert( m_playerUnitsCreationData != null == Network.isServer() or params.has(SavedGame) )

	if params.has(SavedGame):
		assert( is_network_master() )

	Connector.connectGame( self )
	setPaused(true)

	if params.has(SavedGame):
		call_deferred( "loadGame", params[SavedGame] )
	else:
		if is_network_master():
			registerPlayerGameScene( get_tree().get_network_unique_id() )
		else:
			rpc("registerPlayerGameScene", get_tree().get_network_unique_id() )


func _ready():
	connect("quitGameRequested", self, "finish")


func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		toggleGameMenu()


func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		Utility.setFreeing( m_module_ )
		for unit in m_playerUnits:
			if unit[WEAKREF].get_ref() != null:
				assert( unit[WEAKREF].get_ref() == unit[NODE] )
				assert( not unit[NODE].is_inside_tree() )
				unit[NODE].free()


func _input(event):
	if event.is_action_pressed("ui_select"): # TODO: remove
		self.unloadLevel( m_currentLevel )
		pass


func setPaused( enabled ):
	get_tree().set_pause(enabled)
	Utility.emit_signal("sendVariable", "Pause", "Yes" if enabled else "No")


func prepare():
	assert( is_network_master() )
	assert( m_currentLevel == null )
	
	var levelLoader = LevelLoaderGd.new()

	m_playerUnits = createPlayerUnits( m_playerUnitsCreationData )
	m_currentLevel = levelLoader.loadLevel( m_module_.getStartingLevel(), self )
	levelLoader.insertPlayerUnits( m_playerUnits, m_currentLevel )


	for playerId in Network.m_players:
		if playerId == Network.ServerId:
			continue
		levelLoader.sendToClient( playerId, m_currentLevel )

	assignAgentsToPlayerUnits( m_playerUnits )
	rpc("finalizePreparation")


master func registerPlayerGameScene( id ):
	if not id in m_playersWithGameScene:
		m_playersWithGameScene.append( id )
		m_playersWithGameScene.sort()
		var playersIds = Network.m_players.keys()
		playersIds.sort()
		if m_playersWithGameScene == playersIds:
			prepare()


sync func finalizePreparation():
	if is_network_master():
		Network.readyToStart( get_tree().get_network_unique_id() )
	else:
		Network.rpc_id( get_network_master(), "readyToStart", get_tree().get_network_unique_id() )


slave func loadLevel(filePath, parentNodePath):
	var levelLoader = LevelLoaderGd.new()
	levelLoader.loadLevel(filePath, get_tree().get_root().get_node(parentNodePath))


func setCurrentLevel( levelNode ):
	if m_currentLevel:
		unloadLevel( m_currentLevel )
	m_currentLevel = levelNode


func setCurrentModule( moduleNode_ ):
	m_module_ = moduleNode_
	if m_currentLevel:
		unloadLevel( m_currentLevel )
		m_currentLevel = null

	resetPlayerUnits( [] )


remote func start():
	if is_network_master():
		rpc("start")

	setPaused(false)
	emit_signal("gameStarted")


func finish():
	emit_signal("gameEnded")


func createPlayerUnits( unitsCreationData ):
	var playerUnits = []
	for unitData in unitsCreationData:
		var unitNode_ = load( unitData["path"] ).instance()
		unitNode_.set_name( str( Network.m_players[unitData["owner"]] ) + "_" )
		unitNode_.setNameLabel( Network.m_players[unitData["owner"]] )
		playerUnits.append( {OWNER : unitData["owner"], NODE : unitNode_, WEAKREF : weakref(unitNode_) } )

	return playerUnits


func resetPlayerUnits( playerUnitsPaths ):
	m_playerUnits.clear()
	for unitPath in playerUnitsPaths:
		var unit = {}
		unit[NODE] = get_tree().get_root().get_node( unitPath )
		unit[WEAKREF] = weakref( unit[NODE] )
		unit[OWNER] = get_tree().get_network_unique_id()
		unit[NODE].setNameLabel( Network.m_players[unit[OWNER]] )
		m_playerUnits.append(unit)
	assignAgentsToPlayerUnits( m_playerUnits )


func assignAgentsToPlayerUnits( playerUnits ):
	assert( is_network_master() )

	for unit in playerUnits:
		if unit[OWNER] == get_tree().get_network_unique_id():
			assignOwnAgent( unit[NODE].get_path() )
		else:
			rpc_id( unit[OWNER], "assignOwnAgent", unit[NODE].get_path() )


remote func assignOwnAgent( unitNodePath ):
	var unitNode = get_node( unitNodePath )
	assert( unitNode )
	var playerAgent = PlayerAgentGd.new()
	playerAgent.set_network_master( get_tree().get_network_unique_id() )
	playerAgent.assignToUnit( unitNode )


func loadGame(filePath):
	m_serializer.deserialize(filePath)


func unloadLevel( level ):
	# take player units from level
	for playerUnit in m_playerUnits:
		level.removeChildUnit( playerUnit[NODE] )

	var levelLoader = LevelLoaderGd.new()
	levelLoader.unloadLevel( level )


func toggleGameMenu():
	if m_gameMenu == null:
		createGameMenu()
	else:
		deleteGameMenu()


func createGameMenu():
	assert( m_gameMenu == null )
	var gameMenu = preload( GameMenuScn ).instance()
	self.add_child( gameMenu )
	m_gameMenu = gameMenu
	m_gameMenu.initialize( m_serializer )


func deleteGameMenu():
	assert( m_gameMenu != null )
	m_gameMenu.queue_free()
	m_gameMenu = null
