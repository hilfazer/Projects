extends Node

const SavingModuleGd         = preload("res://modules/SavingModule.gd")
const PlayerUnitGd           = preload("res://game/PlayerUnit.gd")
const UtilityGd              = preload("res://Utility.gd")

const WaitForPlayersTime : float = 0.5

var m_game                             setget deleted
var m_module                           setget setModule
var m_playerUnitsCreationData = []     setget setPlayerUnitsCreationData


signal prepared()
signal created()
signal _finishWaitingForPlayers()


func deleted(_a):
	assert(false)


func _init( game, nodeName ):
	m_game = game
	name = nodeName
	assert( game.m_module )
	setModule( game.m_module )


func setModule( module ):
	m_module = module


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
	emit_signal("prepared")


func create():
	assert( is_network_master() )
	var levelFilename = m_module.getStartingLevelFilenameAndEntrance()[0]
	var result = m_game.m_levelLoader.loadLevel( levelFilename )
	if result and result is GDScriptFunctionState:
		yield(m_game.m_levelLoader, "levelLoaded")

	emit_signal("created")


func matchModuleToSavedGame( filePath : String ):
	if m_module and not m_module.moduleMatches( filePath ):
		m_game.setCurrentModule( null )

	if not m_game.m_module:
		var module = SavingModuleGd.createFromSaveFile( filePath )
		if not module:
			Debug.err( self, "could not load game from file %s" % filePath )
			return
		else:
			m_game.setCurrentModule( module )
	else:
		m_module.loadFromFile( filePath )


func _createPlayerUnits( unitsCreationData ) -> Array:
	assert( is_network_master() )

	var playerUnits : Array = []
	for unitData in unitsCreationData:
		var unitNode_ = load( unitData["path"] ).instance()
		unitNode_.set_name( str( Network.m_clients[unitData["owner"]] ) + "_" )
		unitNode_.setNameLabel( Network.m_clients[unitData["owner"]] )

		var playerUnit : PlayerUnitGd = PlayerUnitGd.new( unitNode_, unitData["owner"] )
		playerUnits.append( playerUnit )
	return playerUnits


func _onPlayerConnected( playerId ):
	Debug.info( self, "Creator: Player connected %d" % playerId )
	if _areAllPlayersConnected():
		call_deferred( "emit_signal", "_finishWaitingForPlayers" )



func _areAllPlayersConnected():
	return UtilityGd.isSuperset( m_game.m_rpcTargets, m_game.m_playerManager.m_playerIds )
