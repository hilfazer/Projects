extends Node

const GameMenuScn            = "GameMenu.tscn"
const GameSerializerGd       = preload("./serialization/GameSerializer.gd")
const GameCreator            = preload("./GameCreator.gd")
const PlayerAgentGd          = preload("res://agents/PlayerAgent.gd")
const LevelLoaderGd          = preload("res://levels/LevelLoader.gd")
const LevelBaseGd            = preload("res://levels/LevelBase.gd")
const SavingModuleGd         = preload("res://modules/SavingModule.gd")
const UtilityGd              = preload("res://Utility.gd")

enum Params { Module, PlayerUnitsData, SavedGame, PlayersIds, RequestGameState }

var m_module_ : SavingModuleGd         setget deleted # setCurrentModule
var m_currentLevel                     setget setCurrentLevel
var m_gameMenu                         setget deleted
var m_rpcTargets = []                  setget deleted # setRpcTargets
var m_levelLoader                      setget deleted
var m_creator                          setget deleted
onready var m_playerManager = $"PlayerManager"   setget deleted

signal gameStarted
signal gameEnded
signal predelete
signal quitGameRequested


func deleted(a):
	assert(false)


func _init():
	m_levelLoader = LevelLoaderGd.new()


func _enter_tree():

	var params = SceneSwitcher.getParams()
	
	if not params.has(SavedGame):
		m_creator = GameCreator.new(self)
		call_deferred("add_child", m_creator)
		yield(m_creator, "tree_entered")

	if params.has( Module ):
		m_creator.setModule( params[Module] )
		setCurrentModule( params[Module] )
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
#	setPaused(true)


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
		var playerUnitNodes = m_playerManager.getPlayerUnitNodes()

		var entrance = m_currentLevel.findEntranceWithAllUnits(playerUnitNodes)
		if entrance:
			var filename_entrance = m_module_.getTargetLevelFilenameAndEntrance(m_currentLevel.name, entrance.name)
	
			if filename_entrance != null:
				self.changeLevel( filename_entrance[0], filename_entrance[1] )
			else:
				UtilityGd.log("no connection from entrance " + entrance.name \
							+ " on level " + m_currentLevel.name)
		else:
			UtilityGd.log("You must gather your party before venturing forth.")


func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		UtilityGd.setFreeing( m_module_ )
		emit_signal( "predelete" )


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


func saveLevel( level : LevelBaseGd ):
	m_module_.saveLevel( level )


slave func loadLevel(filePath, parentNodePath):
	return m_levelLoader.loadLevel(filePath, get_tree().get_root().get_node(parentNodePath))


slave func unloadLevel():
	if is_network_master():
		Network.RPC(self, ["unloadLevel"])

	if m_currentLevel:
		m_levelLoader.unloadLevel( self )

	yield(m_levelLoader, "levelUnloaded")
	Console.writeLine("level unloaded")


func setCurrentLevel( levelNode ):
	assert( m_currentLevel == null or levelNode == null )
	m_currentLevel = levelNode


func setCurrentModule( moduleNode_ : SavingModuleGd ):
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
	if is_network_master():
		m_playerManager.createPlayerUnits( unitsCreationData )


func resetPlayerUnits( playerUnitsPaths ):
	if is_network_master():
		m_playerManager.resetPlayerUnits( playerUnitsPaths )


func getPlayerUnits():
	return m_playerManager.getPlayerUnitNodes()
	
	
func spawnPlayerAgents():
	if is_network_master():
		m_playerManager.spawnPlayerAgents()


func loadGame( filePath ):
	UtilityGd.log("loadGame() not implemented")
	return


func saveGame( filePath ):
	UtilityGd.log("saveGame() not implemented")
	return


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


func changeLevel( newLevelName, entranceName ):
	var result = m_levelLoader.loadLevel(newLevelName, self)
	if result and result is GDScriptFunctionState:
		yield(m_levelLoader, "levelLoaded")

	m_levelLoader.insertPlayerUnits(
		m_playerManager.getPlayerUnitNodes(), m_currentLevel, entranceName )

	for clientId in m_rpcTargets:
		sendToClient( clientId )

	spawnPlayerAgents()

