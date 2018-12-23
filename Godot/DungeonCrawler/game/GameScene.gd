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
var m_currentLevel : LevelBaseGd       setget deleted
var m_rpcTargets = []                  setget deleted # setRpcTargets
var m_levelLoader : LevelLoaderGd      setget deleted
var m_creator                          setget deleted
var m_state : int = State.Initial      setget deleted # _changeState

onready var m_playerManager = $"PlayerManager"   setget deleted


signal gameStarted
signal gameFinished
signal predelete


func deleted(_a):
	assert(false)


func _enter_tree():
	setPaused(true)
	var params = SceneSwitcher.getParams()


func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		emit_signal( "predelete" )


func setPaused( enabled : bool ):
	get_tree().paused = enabled
	Debug.updateVariable( "Pause", "Yes" if get_tree().paused else "No")


func finish():
	_changeState( State.Finished )




func createPlayerUnits( unitsCreationData ):
	if is_network_master():
		m_playerManager.createPlayerUnits( unitsCreationData )


func resetPlayerUnits( playerUnitsPaths ):
	if is_network_master():
		m_playerManager.resetPlayerUnits( playerUnitsPaths )


func getPlayerUnits():
	return m_playerManager.getPlayerUnitNodes()


func onNodeRegisteredClientsChanged( nodePath : NodePath, nodesWithClients ):
	if nodePath == get_path():
		setRpcTargets( nodesWithClients[nodePath] )


func setRpcTargets( clientIds : Array ):
	assert( Network.isServer() )
	m_rpcTargets = clientIds


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
