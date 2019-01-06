extends Node

const ModuleGd               = preload("res://core/Module.gd")
const SavingModuleGd         = preload("res://core/SavingModule.gd")
const SerializerGd           = preload("res://core/Serializer.gd")
const UtilityGd              = preload("res://core/Utility.gd")
const PlayerUnitGd           = preload("./PlayerUnit.gd")

const WaitForPlayersTime : float = 0.5

var m_game                             setget deleted
var m_playerUnitsCreationData = []     setget setPlayerUnitsCreationData


signal prepareFinished( error )
signal createFinished( error )
signal _finishWaitingForPlayers()


func deleted(_a):
	assert(false)


func setGame( game : Node ):
	m_game = game


func setPlayerUnitsCreationData( data ):
	m_playerUnitsCreationData = data


func prepare():
	assert( is_inside_tree() )
	assert( is_network_master() )
	assert( m_game.m_currentLevel == null )

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
	var levelFilename = m_game.m_module.getStartingLevelFilenameAndEntrance()[0]
	var entranceName = m_game.m_module.getStartingLevelFilenameAndEntrance()[1]

	var result = _loadlevel( levelFilename, m_game.m_module.getStartingLevelName(), null )
#	var result = m_game.m_levelLoader.loadLevel( levelFilename, m_game.m_currentLevelParent )
	if result is GDScriptFunctionState:
		result = yield( result, "completed" )

	var unitNodes : Array = []
	for playerUnit in m_game.m_playerManager.m_playerUnits:
		unitNodes.append( playerUnit.m_unitNode_ )

	m_game.m_levelLoader.insertPlayerUnits(
		unitNodes, m_game.m_currentLevel, entranceName )
	emit_signal( "createFinished", result )


func loadGame( filePath : String ) -> int:
	if not m_game.m_module or not m_game.m_module.moduleMatches( filePath ):
		var result = _createNewModule( filePath )
		if result is GDScriptFunctionState:
			result = yield( result, "completed" )
		if result != OK:
			Debug.err( self, "Could not create module from %s" % filePath )
			return result
	else:
		m_game.m_module.loadFromFile( filePath )

	var module : SavingModuleGd = m_game.m_module

	var result = m_game.m_levelLoader.loadLevel(
		module.getLevelFilename( module.getCurrentLevelName() ),
		m_game.m_currentLevelParent
			)
	if result is GDScriptFunctionState:
		result = yield( result, "completed" )

	var levelState = module.loadLevelState( module.getCurrentLevelName(), false )
	if levelState:
		SerializerGd.deserialize(
			[module.getCurrentLevelName(), levelState], m_game.m_currentLevelParent )
	return result


func loadLevel( levelName : String ):
	var module : SavingModuleGd = m_game.m_module
	var fileName = module.getLevelFilename( levelName )
	if fileName.empty():
		return ERR_CANT_CREATE

	var levelState = module.loadLevelState( levelName, true )

	var result = _loadlevel( fileName, levelName, levelState )
	if result is GDScriptFunctionState:
		result = yield( result, "completed" )

	return result


puppet func _loadlevel( filePath : String, levelName, levelState = null ):
	var result = m_game.m_levelLoader.loadLevel(
		filePath, m_game.m_currentLevelParent )
	if result is GDScriptFunctionState:
		result = yield( result, "completed" )

	if result != OK:
		return result

	if levelState != null:
		SerializerGd.deserialize( [levelName, levelState], m_game.m_currentLevelParent )

	return OK


func _createNewModule( filePath : String ) -> int:
	var result = m_game.setCurrentModule( null )
	if result is GDScriptFunctionState:
		result = yield( result, "completed" )

	var module = SavingModuleGd.createFromSaveFile( filePath )
	if not module:
		Debug.err( null, "Could not load game from file %s" % filePath )
		return ERR_CANT_CREATE
	else:
		result = m_game.setCurrentModule( module )
		if result is GDScriptFunctionState:
			result = yield( result, "completed" )
	return OK


func _createPlayerUnits( unitsCreationData : Array ) -> Array:
	assert( is_network_master() )

	var playerUnits : Array = []
	for unitDatum in unitsCreationData:
		assert( unitDatum is Dictionary )
		var fileName = m_game.m_module.getUnitFilename( unitDatum.name )
		if fileName.empty():
			continue

		var unitNode_ = load( fileName ).instance()
		unitNode_.set_name( str( Network.m_clients[unitDatum.owner] ) + "_" )
		unitNode_.setNameLabel( Network.m_clients[unitDatum.owner] )

		var playerUnit : PlayerUnitGd = PlayerUnitGd.new( unitNode_, unitDatum.owner )
		playerUnits.append( playerUnit )
	return playerUnits


func _onPlayerConnected( playerId : int ):
	Debug.info( self, "Creator: Player connected %d" % playerId )
	if _areAllPlayersConnected():
		call_deferred( "emit_signal", "_finishWaitingForPlayers" )


func _areAllPlayersConnected():
	return UtilityGd.isSuperset(
		m_game.m_rpcTargets, m_game.m_playerManager.m_playerIds )


static func makeUnitDatum():
	return { name = "", owner = 0 }
