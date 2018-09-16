extends Node

const GameCreatorGd          = preload("./GameCreator.gd")
const LevelLoaderGd          = preload("res://levels/LevelLoader.gd")
const LevelBaseGd            = preload("res://levels/LevelBase.gd")
const SavingModuleGd         = preload("res://modules/SavingModule.gd")
const SerializerGd           = preload("res://modules/Serializer.gd")
const UtilityGd              = preload("res://Utility.gd")

enum Params { Module, PlayerUnitsData, SavedGame, PlayersIds, RequestGameState }
enum State { Initial, Creating, Running, Finished }

var m_module : SavingModuleGd          setget deleted # setCurrentModule
var m_currentLevel : LevelBaseGd       setget setCurrentLevel
var m_rpcTargets = []                  setget deleted # setRpcTargets
var m_levelLoader : LevelLoaderGd      setget deleted
var m_creator                          setget deleted
var m_state : int = Initial            setget deleted # _changeState
onready var m_playerManager = $"PlayerManager"   setget deleted
var m_gameStateRequests = PoolIntArray()         setget deleted

signal gameStarted
signal gameFinished
signal predelete


func deleted(a):
	assert(false)


func _init():
	m_levelLoader = LevelLoaderGd.new()


func _enter_tree():
	setPaused(true)
	var params = SceneSwitcher.getParams()

	if is_network_master():
		m_creator = GameCreatorGd.new(self)
		call_deferred("add_child", m_creator)
		yield(m_creator, "tree_entered")
		m_creator.connect( "finished", self, "start", [], CONNECT_ONESHOT )


	if params.has( Module ) and params[Module]:
		setCurrentModule( params[Module] )
		m_creator.setModule( params[Module] )
		assert( m_module != null == Network.isServer() or params.has(SavedGame) )


	if params.has( PlayerUnitsData ) and params[PlayerUnitsData]:
		m_creator.setPlayerUnitsCreationData( params[PlayerUnitsData] )
		assert( params[PlayerUnitsData] != null == Network.isServer() or params.has(SavedGame) )


	if params.has( PlayersIds ) and Network.isServer():
		setRpcTargets( params[PlayersIds] )
		m_creator.setPlayersIds( params[PlayersIds] )


	Connector.connectGame( self )


	if params.has(SavedGame) and params[SavedGame]:
		assert( is_network_master() )
		call_deferred( "loadGame", params[SavedGame] )
	elif is_network_master():
		call_deferred( "_changeState", Creating )
		m_creator.call_deferred( "prepare" )


	if Network.isServer():
		Network.connect("nodeRegisteredClientsChanged", self, "onNodeRegisteredClientsChanged")

	if params.has( RequestGameState ):
		if Network.isServer():
			assert( params[RequestGameState] != true )
		elif params[RequestGameState] == true:
			call_deferred( "requestGameState", get_tree().get_network_unique_id() )


func _exit_tree():
	if Network.isClient():
		Network.rpc( "unregisterNodeForClient", get_path() )


func _unhandled_input(event):
	if event.is_action_pressed("ui_select"): #todo: remove
		var playerUnitNodes = m_playerManager.getPlayerUnitNodes()

		var entrance = m_currentLevel.findEntranceWithAllUnits(playerUnitNodes)
		if entrance:
			var filename_entrance = m_module.getTargetLevelFilenameAndEntrance(m_currentLevel.name, entrance.name)

			if filename_entrance != null:
				self.changeLevel( filename_entrance[0], filename_entrance[1] )
				$GUI/LogLabel.setMessage("")
			else:
				UtilityGd.log("no connection from entrance %s on level %s" \
							% [entrance.name, m_currentLevel.name])
		else:
			$GUI/LogLabel.setMessage("You must gather your party before venturing forth.")


func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		emit_signal( "predelete" )


func setPaused( enabled : bool ):
	get_tree().paused = enabled
	Connector.updateVariable( "Pause", "Yes" if get_tree().paused else "No")


func saveLevel( level : LevelBaseGd ):
	m_module.saveLevel( level )


slave func loadLevel( filePath : String ):
	return m_levelLoader.loadLevel(filePath, self)


slave func unloadLevel():
	if is_network_master():
		Network.RPC(self, ["unloadLevel"])

	if m_currentLevel:
		yield(m_levelLoader.unloadLevel(self), "completed")


slave func deserializeLevel( levelName, serializedData ):
	SerializerGd.deserialize( [levelName, serializedData], self )


func setCurrentLevel( levelNode : LevelBaseGd ):
	assert( m_currentLevel == null or levelNode == null )
	m_currentLevel = levelNode
	if m_currentLevel:
		m_currentLevel.connect("tree_exited", self, "setCurrentLevel", [null], CONNECT_ONESHOT)


func changeLevel( newLevelFilename, entranceName ):
	var result = m_levelLoader.loadLevel(newLevelFilename, self)
	if result and result is GDScriptFunctionState:
		yield(m_levelLoader, "levelLoaded")

	var savedLevelState = m_module.loadLevelState( m_currentLevel.name )
	if savedLevelState:
		deserializeLevel( m_currentLevel.name, savedLevelState )
	m_levelLoader.insertPlayerUnits(
		m_playerManager.getPlayerUnitNodes(), m_currentLevel, entranceName )

	for clientId in m_rpcTargets:
		sendToClient( clientId )

	spawnPlayerAgents()


func setCurrentModule( moduleNode_ : SavingModuleGd ):
	if m_module:
		m_module.free()
	m_module = moduleNode_
	if m_currentLevel:
		m_levelLoader.unloadLevel( self )
		yield( m_levelLoader, "levelUnloaded" )
		assert( m_currentLevel == null )


slave func start():
	_changeState( Running )
	if is_network_master():
		rpc("start")

	emit_signal("gameStarted")


func finish():
	_changeState( Finished )


func saveGame( filePath : String ):
	assert( m_currentLevel )
	m_module.saveLevel( m_currentLevel )
	m_module.savePlayerUnits( UtilityGd.toPaths( m_playerManager.getPlayerUnitNodes() ) )
	m_module.saveToFile( filePath ) && UtilityGd.log("Game saved")


func loadGame( filePath : String ):
	_changeState( Creating )
	var scopeExit = UtilityGd.scopeExit(self, "_changeState", [Running])

	var result = unloadLevel()
	if result and result is GDScriptFunctionState:
		yield(m_levelLoader, "levelUnloaded")

	m_creator.matchModuleToSavedGame( filePath )

	var levelFilename = m_module.getLevelFilename( m_module.getCurrentLevelName() )
	result = m_levelLoader.loadLevel( levelFilename, self )
	if result and result is GDScriptFunctionState:
		yield(m_levelLoader, "levelLoaded")

	deserializeLevel( m_currentLevel.name, m_module.loadLevelState( m_currentLevel.name ) )
	resetPlayerUnits( m_module.getPlayerUnitsPaths() )
	UtilityGd.log("Game loaded")

	for clientId in m_rpcTargets:
		sendToClient( clientId )


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


func onNodeRegisteredClientsChanged( nodePath : NodePath ):
	if nodePath == get_path():
		setRpcTargets( Network.m_nodesWithClients[nodePath] )


func setRpcTargets( clientIds : Array ):
	assert( Network.isServer() )
	m_rpcTargets = clientIds


func sendToClient( clientId : int ):
	assert( is_network_master() )

	if ( get_tree().get_rpc_sender_id() != 0 \
		and get_tree().get_rpc_sender_id() != clientId
		):
		return

	var nameAndState = SerializerGd.serialize( m_currentLevel )
	rpc_id( clientId, "receiveGameState", nameAndState )


remote func requestGameState( clientId : int ):
	if not is_network_master():
		rpc_id( get_network_master(), "requestGameState", get_tree().get_network_unique_id() )
	else:
		if m_state in [Initial, Creating] and not clientId in m_gameStateRequests:
			m_gameStateRequests.append( clientId )
		else:
			sendToClient( clientId )


slave func receiveGameState( serializedLevel : Array ):
	setPaused( true )
	var result = loadLevel( serializedLevel[1]['SCENE'] )
	if result and result is GDScriptFunctionState:
		yield(m_levelLoader, "levelLoaded")

	SerializerGd.deserialize( serializedLevel, self )

	setPaused( false )
	Network.rpc( "registerNodeForClient", get_path() )


func _changeState( state : int ):
	assert( state != Initial )
	assert( m_state != Finished )

	if state == m_state:
		UtilityGd.log("changing to same state")
		return

	if state == Finished:
		emit_signal("gameFinished")

	elif state == Running:
		setPaused(false)
		if m_state == Creating:
			for clientId in m_gameStateRequests:
				sendToClient( clientId )
			m_gameStateRequests.resize(0)

	elif state == Creating:
		setPaused(true)

	m_state = state
