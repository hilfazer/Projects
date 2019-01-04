extends Node

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


func _init( game, nodeName : String ):
	m_game = game
	name = nodeName


func setPlayerUnitsCreationData( data ):
	m_playerUnitsCreationData = data


func prepare():
	assert( is_inside_tree() )
	assert( is_network_master() )
	assert( m_game.m_currentLevel == null )

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

	var result = m_game.m_levelLoader.loadLevel( levelFilename, m_game.m_currentLevelParent )
	if result is GDScriptFunctionState:
		result = yield( result, "completed" )

	emit_signal( "createFinished", result )


func loadGame( filepath : String ) -> int:
	matchModuleToSavedGame( filepath, m_game )
	var module : SavingModuleGd = m_game.m_module
	module.loadFromFile( filepath )
	var result = m_game.m_levelLoader.loadLevel(
		module.getLevelFilename(
			module.getCurrentLevelName() ), m_game.m_currentLevelParent )
	if result is GDScriptFunctionState:
		result = yield( result, "completed" )

	var levelState = module.loadLevelState( module.getCurrentLevelName(), false )
	SerializerGd.deserialize(
		[module.getCurrentLevelName(), levelState], m_game.m_currentLevelParent )
	return result


static func matchModuleToSavedGame( filePath : String, game : Node ):
	if game.m_module and not game.m_module.moduleMatches( filePath ):
		game.setCurrentModule( null )

	if not game.m_module:
		var module = SavingModuleGd.createFromSaveFile( filePath )
		if not module:
			Debug.err( null, "could not load game from file %s" % filePath )
			return
		else:
			game.setCurrentModule( module )


func _createPlayerUnits( unitsCreationData : Array ) -> Array:
	assert( is_network_master() )

	var playerUnits : Array = []
	for unitData in unitsCreationData:
		var unitNode_ = load( unitData["path"] ).instance()
		unitNode_.set_name( str( Network.m_clients[unitData["owner"]] ) + "_" )
		unitNode_.setNameLabel( Network.m_clients[unitData["owner"]] )

		var playerUnit : PlayerUnitGd = PlayerUnitGd.new( unitNode_, unitData["owner"] )
		playerUnits.append( playerUnit )
	return playerUnits


func _onPlayerConnected( playerId : int ):
	Debug.info( self, "Creator: Player connected %d" % playerId )
	if _areAllPlayersConnected():
		call_deferred( "emit_signal", "_finishWaitingForPlayers" )


func _areAllPlayersConnected():
	return UtilityGd.isSuperset( m_game.m_rpcTargets, m_game.m_playerManager.m_playerIds )
