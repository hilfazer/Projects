extends "res://core/game/GameCreator.gd"

const GameCreatorClientGd    = preload("./GameCreatorClient.gd")

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


func createFromModule( module : SavingModuleGd ) -> int:
	assert( m_game.m_module == null )
	yield( m_game.setCurrentModule( module ), "completed" )
	Network.RPC( self, ["setModuleFromFile", module.m_moduleFilename] )

	var result = yield( _create(), "completed" )
	return result


func createFromFile( filePath : String ) -> int:
	if not m_game.m_module or not m_game.m_module.moduleMatches( filePath ):
		var result = yield( _createNewModule( filePath ), "completed" )
		if result != OK:
			Debug.err( self, "Could not create module from %s" % filePath )
			return result
		else:
			Network.RPC( self, ["setModuleFromFile", m_game.m_module.m_moduleFilename] )
	else:
		m_game.m_module.loadFromFile( filePath )

	var result = yield( _create(), "completed" )
	return result


func _create() -> int:
	assert( is_network_master() )
	assert( m_game.m_module )

	var module = m_game.m_module
	var levelName = module.getCurrentLevelName()
	var levelState = module.loadLevelState( levelName, true )

	Network.RPC( self, ["loadLevel", levelName, levelState] )
	var result = yield( _loadLevel( levelName, levelState ), "completed" )


	var entranceName = module.getLevelEntrance( levelName )
	if not entranceName.empty():
		Network.RPC( self,
			["createAndInsertUnits", m_playerUnitsCreationData, entranceName] )
		_createAndInsertUnits( m_playerUnitsCreationData, entranceName )
	elif not m_playerUnitsCreationData.empty():
		Debug.warn( self, \
			"No default entrance for level %s. Could not create player units" % levelName )

	m_playerUnitsCreationData.clear()

	Network.RPC( self, ["finalizeCreation", result] )
	emit_signal( "createFinished", result )
	return result


func unloadCurrentLevel():
	var result = yield( m_game.m_levelLoader.unloadLevel(), "completed" )


func _createNewModule( filePath : String ) -> int:
	var result = yield( m_game.setCurrentModule( null ), "completed" ) \
		if m_game.m_module != null \
		else yield( get_tree(), "idle_frame" )

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

