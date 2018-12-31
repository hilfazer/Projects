extends Node

const GameCreatorGd          = preload("./GameCreator.gd")
const LevelLoaderGd          = preload("res://levels/LevelLoader.gd")
const LevelBaseGd            = preload("res://levels/LevelBase.gd")
const SavingModuleGd         = preload("res://modules/SavingModule.gd")
const SerializerGd           = preload("res://modules/Serializer.gd")
const UtilityGd              = preload("res://Utility.gd")

const GameCreatorName        = "GameCreator"

enum Params { Module, PlayerUnitsData, SavedGame, PlayerIds }
enum State { Initial, Creating, Running, Finished }

var m_module : SavingModuleGd          setget deleted # setCurrentModule
var m_currentLevel : LevelBaseGd       setget deleted
var m_rpcTargets : Array = []          # _setRpcTargets
var m_levelLoader : LevelLoaderGd      setget deleted
var m_creator : GameCreatorGd          setget deleted
var m_state : int = State.Initial      setget deleted # _changeState

onready var m_playerManager = $"PlayerManager"   setget deleted


signal gameStarted()
signal gameFinished()
signal playerReady( id )


func deleted(_a):
	assert(false)


func _enter_tree():
	OS.delay_msec( int(Debug.m_createGameDelay * 1000) )
	Network.connect("clientListChanged", self, "_adjustToClients")


func _ready():
	var params = SceneSwitcher.getParams()

	if params.has( Params.PlayerIds ) and Network.isServer():
		m_playerManager.setPlayerIds( params[Params.PlayerIds] )
		Debug.info( self, "GameScene: Players set " + str( m_playerManager.getPlayerIds() ) )

	if is_network_master():
		m_creator = GameCreatorGd.new( self, GameCreatorName )
		call_deferred( "add_child", m_creator )
		yield( m_creator, "tree_entered" )
		m_creator.call_deferred( "prepare" )

	if Network.isServer():
		Network.connect("nodeRegisteredClientsChanged", self, "_onNodeRegisteredClientsChanged")

	if is_network_master() == false:
		Network.RPCmaster( self, ["onClientReady"] )


func _exit_tree():
	if Network.isClient():
		Network.RPCmaster( Network, ["unregisterNodeForClient", get_path()] )


master func onClientReady():
	var clientId = get_tree().get_rpc_sender_id()
	match m_state:
		State.Initial:
			if clientId in m_playerManager.getPlayerIds():
				Network.RPCid( self, clientId, ["receiveGameState", m_state] )
		State.Running:
			pass
		State.Creating:
			pass


puppet func receiveGameState( state : int ):
	match( state ):
		State.Initial:
			Network.RPCmaster( Network, ["registerNodeForClient", get_path()] )
		State.Finished:
			pass


func start():
	print( "-----\nGAME START\n-----" )
	setPaused( false )
	_changeState( State.Running )
	emit_signal("gameStarted")


func setPaused( enabled : bool ):
	get_tree().paused = enabled
	Debug.updateVariable( "Pause", "Yes" if get_tree().paused else "No" )


puppet func finish():
	if is_network_master():
		Network.RPC( self, ["finish"] )

	_changeState( State.Finished )


func unloadLevel():
	print("unloadLevel() not implemented")


func getPlayerUnits():
	return m_playerManager.getPlayerUnitNodes()


func onNodeRegisteredClientsChanged( nodePath : NodePath, nodesWithClients ):
	if nodePath == get_path():
		_setRpcTargets( nodesWithClients[nodePath] )


func _adjustToClients( clients : Dictionary ):
	var newRpcTargets : Array = []
	for target in m_rpcTargets:
		if target in clients.keys():
			newRpcTargets.append( target )

	if newRpcTargets != m_rpcTargets:
		_setRpcTargets( newRpcTargets )


func _changeState( state : int ):
	assert( state != State.Initial )
	assert( m_state != State.Finished )

	if state == m_state:
		Debug.warn(self, "changing to same state")
		return

	if state == State.Finished:
		emit_signal("gameFinished")

	elif state == State.Running:
		setPaused(false)

	elif state == State.Creating:
		setPaused(true)

	m_state = state


func _onNodeRegisteredClientsChanged( nodePath : NodePath, nodesWithClients ):
	if nodePath != get_path():
		return

	var clients : Array = nodesWithClients[nodePath]
	var newPlayers : Array = []
	var newTargets : Array = []
	for clientId in clients:
		if clientId in m_playerManager.m_playerIds:
			newTargets.append( clientId )
			if not clientId in m_rpcTargets:
				newPlayers.append( clientId )

	_setRpcTargets( newTargets )
	for playerId in newPlayers:
		emit_signal( "playerReady", playerId )


func _setRpcTargets( clientIds : Array ):
	assert( Network.isServer() )
	assert( not Network.ServerId in clientIds )
	Network.setRpcTargets( self, clientIds )

