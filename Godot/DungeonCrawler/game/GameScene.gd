extends Node

const GameCreatorGd          = preload("./GameCreator.gd")
const LevelLoaderGd          = preload("res://levels/LevelLoader.gd")
const LevelBaseGd            = preload("res://levels/LevelBase.gd")
const SavingModuleGd         = preload("res://modules/SavingModule.gd")
const SerializerGd           = preload("res://modules/Serializer.gd")
const UtilityGd              = preload("res://Utility.gd")

const GameCreatorName        = "GameCreator"

enum Params { Module, PlayerUnitsData, SavedGame, PlayerIds, RequestGameState }
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
		Network.RPCmaster( self, ["unregisterNodeForClient", get_path()] )


master func onClientReady():
	match m_state:
		State.Initial:
			if get_tree().get_rpc_sender_id() in m_playerManager.getPlayerIds():
				_setRpcTargets( m_rpcTargets + [get_tree().get_rpc_sender_id()] )
				emit_signal( "playerReady", get_tree().get_rpc_sender_id() )
		State.Running:
			pass
		State.Creating:
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
	if nodePath == get_path():
		_setRpcTargets( nodesWithClients[nodePath] )


func _setRpcTargets( clientIds : Array ):
	assert( Network.isServer() )
	Network.setRpcTargets( self, clientIds )

