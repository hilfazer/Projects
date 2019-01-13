extends "res://core/game/GameCreator.gd"

const GameCreatorClientGd    = preload("./GameCreatorClient.gd")

const Requests = GameCreatorClientGd.Requests
const WaitForPlayersTime : float = 0.5

var m_playerUnitsCreationData = []     setget setPlayerUnitsCreationData
var m_rpcTargets : Array = []

signal prepareFinished( error )
signal _finishWaitingForPlayers()


func setPlayerUnitsCreationData( data ):
	m_playerUnitsCreationData = data


func prepare():
	assert( is_inside_tree() )
	assert( is_network_master() )
	assert( m_game.m_currentLevel == null )
	yield( get_tree(), "idle_frame" )

	m_game.m_playerManager.setPlayerUnits(
		_createPlayerUnits( m_playerUnitsCreationData ) )

	m_game.connect( "playerReady", self, "_onPlayerConnected" )
	if not _areAllPlayersConnected():
		var waitTimer = Timer.new()
		waitTimer.connect("timeout", self, "emit_signal", ["_finishWaitingForPlayers"] )
		waitTimer.start( WaitForPlayersTime )
		add_child( waitTimer )
		yield( self, "_finishWaitingForPlayers" )
		waitTimer.paused = true
		waitTimer.queue_free()
		Debug.info( self, "Creator: Finished waiting for players. Connected " + str(m_game.m_rpcTargets) )
	else:
		Debug.info( self, "Creator: All players already connected" )

	m_game.disconnect( "playerReady", self, "_onPlayerConnected" )
	emit_signal( "prepareFinished", OK )


func create():
	assert( is_network_master() )
	assert( m_game.m_module )
	var levelName = m_game.m_module.getStartingLevelName()
	var levelFilename = m_game.m_module.getStartingLevelFilenameAndEntrance()[0]
	var entranceName = m_game.m_module.getStartingLevelFilenameAndEntrance()[1]

	Network.RPC( self, ["addRequest", Requests.LoadLevel, [levelFilename, levelName, null]] )

	var result = yield( _loadLevel( levelFilename, levelName, null ), "completed" )

	Network.RPC( self, ["addRequest", Requests.InsertUnits, [m_playerUnitsCreationData, entranceName]] )

	var unitNodes : Array = []
	for playerUnit in m_game.m_playerManager.m_playerUnits:
		unitNodes.append( playerUnit.m_unitNode_ )

	m_game.m_levelLoader.insertPlayerUnits(
		unitNodes, m_game.m_currentLevel, entranceName )

	Network.RPC( self, ["addRequest", Requests.Finish] )
	emit_signal( "createFinished", result )


func loadGame( filePath : String ) -> int:
	if not m_game.m_module or not m_game.m_module.moduleMatches( filePath ):
		var result = yield( _createNewModule( filePath ), "completed" )
		if result != OK:
			Debug.err( self, "Could not create module from %s" % filePath )
			return result
	else:
		m_game.m_module.loadFromFile( filePath )

	var module : SavingModuleGd = m_game.m_module

	var result = yield(
		m_game.m_levelLoader.loadLevel(
			module.getLevelFilename( module.getCurrentLevelName() ),
			m_game.m_currentLevelParent
			)
		, "completed"
		)

	var levelState = module.loadLevelState( module.getCurrentLevelName(), false )
	if levelState:
		SerializerGd.deserialize(
			[module.getCurrentLevelName(), levelState], m_game.m_currentLevelParent )
	return result


func loadLevel( levelName : String ):
	yield( get_tree(), "idle_frame" )
	var module : SavingModuleGd = m_game.m_module
	var fileName = module.getLevelFilename( levelName )
	if fileName.empty():
		return ERR_CANT_CREATE

	var levelState = module.loadLevelState( levelName, true )
	var result = yield( _loadLevel( fileName, levelName, levelState ), "completed" )
	return result


func unloadCurrentLevel():
	Network.RPC( self, ["addRequest", Requests.UnloadLevel] )
	var result = yield( m_game.m_levelLoader.unloadLevel(), "completed" )


func _createNewModule( filePath : String ) -> int:
	var result = yield( m_game.setCurrentModule( null ), "completed" )

	var module = SavingModuleGd.createFromSaveFile( filePath )
	if not module:
		Debug.err( null, "Could not load game from file %s" % filePath )
		return ERR_CANT_CREATE
	else:
		result = yield( m_game.setCurrentModule( module ), "completed" )
	return OK

func _onPlayerConnected( playerId : int ):
	Debug.info( self, "Creator: Player connected %d" % playerId )
	if _areAllPlayersConnected():
		call_deferred( "emit_signal", "_finishWaitingForPlayers" )


func _areAllPlayersConnected():
	return UtilityGd.isSuperset(
		m_game.m_rpcTargets, m_game.m_playerManager.m_playerIds )

