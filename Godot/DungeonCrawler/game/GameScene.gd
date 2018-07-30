extends Node

const GameMenuScn = "GameMenu.tscn"
const GameSerializerGd = preload("./serialization/GameSerializer.gd")
const GameCreator      = preload("./GameCreator.gd")
const PlayerAgentGd    = preload("res://agents/PlayerAgent.gd")
const LevelLoaderGd    = preload("res://levels/LevelLoader.gd")

enum UnitFields { OWNER, NODE, WEAKREF }
enum Params { Module, PlayerUnitsData, SavedGame, PlayersIds, RequestGameState }

var m_module_                         setget deleted # setCurrentModule
var m_playerUnits = []                setget deleted
var m_currentLevel                    setget setCurrentLevel
var m_gameMenu                        setget deleted
var m_rpcTargets = []                 setget deleted # setRpcTargets
var m_levelLoader                     setget deleted
var m_serializer                      setget deleted
var m_creator                         setget deleted

signal gameStarted
signal gameEnded
signal quitGameRequested


func deleted():
	assert(false)


func _init():
	m_levelLoader = LevelLoaderGd.new()
	m_serializer = GameSerializerGd.new(self)


func _enter_tree():
	m_creator = GameCreator.new(self)
	call_deferred("add_child", m_creator)
	yield(m_creator, "tree_entered")
	
	var params = SceneSwitcher.getParams()

	if params.has( Module ):
		m_creator.setModule( params[Module] )
		m_module_ = params[Module]
		assert( m_module_ != null == Network.isServer() or params.has(SavedGame) )


	if params.has( PlayerUnitsData ):
		m_creator.setPlayerUnitsCreationData( params[PlayerUnitsData] )
		assert( params[PlayerUnitsData] != null == Network.isServer() or params.has(SavedGame) )


	if params.has( SavedGame ):
		assert( is_network_master() )


	if params.has( PlayersIds ) and Network.isServer():
		setRpcTargets( params[PlayersIds] )
		m_creator.setPlayersIds( params[PlayersIds] )


	Connector.connectGame( self )
	setPaused(true)


	if params.has(SavedGame):
		call_deferred( "loadGame", params[SavedGame] )
	else:
		if is_network_master():
			registerPlayerGameScene( get_tree().get_network_unique_id() )
		else:
			rpc("registerPlayerGameScene", get_tree().get_network_unique_id() )

	if Network.isServer():
		Network.connect("nodeRegisteredClientsChanged", self, "onNodeRegisteredClientsChanged")

	if params.has( RequestGameState ):
		if Network.isServer():
			assert( params[RequestGameState] != true )
		elif params[RequestGameState] == true:
			call_deferred( "requestGameState" )


func _exit_tree():
	if get_tree().has_network_peer():
		Network.rpc( "unregisterNodeForClient", get_path() )
	unregisterCommands()


func _ready():
	connect("quitGameRequested", self, "finish")
	registerCommands()


func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		toggleGameMenu()
	if event.is_action_pressed("ui_select"): #todo: remove
		self.changeLevel( "res://levels/Level2.tscn" )


func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		Utility.setFreeing( m_module_ )
		for unit in m_playerUnits:
			if unit[WEAKREF].get_ref() != null:
				assert( unit[WEAKREF].get_ref() == unit[NODE] )
				assert( not unit[NODE].is_inside_tree() )
				unit[NODE].free()


func registerCommands():
	if not is_network_master():
		return

	Console.register('unloadLevel', {
		'description' : "unloads current level",
		'target' : [self, 'unloadLevel']
	} )


func unregisterCommands():
	Console.deregister('unloadLevel')


func setPaused( enabled ):
	get_tree().set_pause(enabled)
	Connector.updateVariable( "Pause", "Yes" if enabled else "No")


master func registerPlayerGameScene( id ):
	assert( is_network_master() )
	if ( m_creator ):
		m_creator.registerPlayerWithGameScene( id )


slave func loadLevel(filePath, parentNodePath):
	return m_levelLoader.loadLevel(filePath, get_tree().get_root().get_node(parentNodePath))


func unloadLevel():
	if m_currentLevel:
		m_levelLoader.unloadLevel( self )

	yield(m_levelLoader, "levelUnloaded")
	Console.writeLine("level unloaded")


func setCurrentLevel( levelNode ):
	assert( m_currentLevel == null or levelNode == null )
	m_currentLevel = levelNode


func setCurrentModule( moduleNode_ ):
	m_module_ = moduleNode_
	if m_currentLevel:
		m_levelLoader.unloadLevel( self )
		yield( m_levelLoader, "levelUnloaded" )
		assert( m_currentLevel == null )

	resetPlayerUnits( [] )


func setRpcTargets( clientIds ):
	assert( Network.isServer() )
	m_rpcTargets = clientIds


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

	for unit in m_playerUnits:
		Utility.setFreeing( unit[NODE] )

	m_playerUnits = playerUnits


func resetPlayerUnits( playerUnitsPaths ):
	for unit in m_playerUnits:
		Utility.setFreeing( unit[NODE] )

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



func loadGame( filePath ):
	setPaused(true)
	var result = m_serializer.deserialize( filePath )
	if result and result is GDScriptFunctionState:
		yield(m_serializer, "deserializationComplete")

	for playerId in Network.getOtherPlayersIds():
		sendToClient( playerId )

	if m_gameMenu:
		deleteGameMenu()
	setPaused(false)


func saveGame( filePath ):
	setPaused(true)
	m_serializer.serialize( filePath )
	setPaused(false)


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


func deleteGameMenu():
	assert( m_gameMenu != null )
	m_gameMenu.queue_free()
	m_gameMenu = null


func onNodeRegisteredClientsChanged( nodePath ):
	if nodePath == get_path():
		setRpcTargets( Network.m_nodesWithClients[nodePath] )


master func sendToClient( clientId ):
	assert( is_network_master() )

	if ( get_tree().get_rpc_sender_id() != 0 \
		and get_tree().get_rpc_sender_id() != clientId
		):
		return

	Network.unregisterAllNodesForClient( clientId )
	var currentLevelFilename = m_currentLevel.filename
	var currentLevelState = m_currentLevel.serialize()
	rpc_id( clientId, "receiveGameState", currentLevelFilename, currentLevelState )


func requestGameState():
	assert( not is_network_master() )
	rpc_id( Network.ServerId, "sendToClient", get_tree().get_network_unique_id() )


slave func receiveGameState( currentLevelFilename, currentLevelState ):
	setPaused( true )
	var result = loadLevel( currentLevelFilename, get_path() )
	if result and result is GDScriptFunctionState:
		yield(m_levelLoader, "levelLoaded")

	m_currentLevel.deserialize( currentLevelState )

	setPaused( false )
	Network.rpc( "registerNodeForClient", get_path() )


func changeLevel(newLevelName):
	m_levelLoader.unloadLevel( self )
	yield( m_levelLoader, "levelUnloaded" )
	m_levelLoader.loadLevel(newLevelName, self)
	m_levelLoader.insertPlayerUnits( m_playerUnits, m_currentLevel )
	
	for clientId in m_rpcTargets:
		sendToClient( clientId )
	
