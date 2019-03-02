extends Node

const GameCreatorGd          = preload("./GameCreator.gd")
const SavingModuleGd         = preload("res://core/SavingModule.gd")
const LevelBaseGd            = preload("res://core/level/LevelBase.gd")
const UtilityGd              = preload("res://core/Utility.gd")

enum Params { Module, PlayerUnitsData }
enum State { Initial, Creating, Saving, Running, Finished }

var m_module : SavingModuleGd          setget setCurrentModule
var m_currentLevel : LevelBaseGd       setget setCurrentLevel
var m_state : int = State.Initial      setget deleted # _changeState
var m_pause := true                    setget setPause

onready var m_creator : GameCreatorGd  = $"GameCreator"
onready var m_currentLevelParent       = $"GameWorldView/Viewport"
onready var m_playerManager            = $"PlayerManager"   setget deleted


signal readyCompleted()
signal gameStarted()
signal gameFinished()


func deleted(_a):
	assert(false)


func _ready():
	m_creator.initialize( self )

	var params = SceneSwitcher.getParams()
	if params == null:
		emit_signal("readyCompleted")
		return

	var module : SavingModuleGd = null
	if params.has( Params.Module ) and params[Params.Module] != null:
		module = params[Params.Module]
	else:
		Debug.err( self, "No module. Can't create game." )
		finish()
		return

	var unitsCreationData := []
	if params.has( Params.PlayerUnitsData ):
		unitsCreationData = params[Params.PlayerUnitsData]

	call_deferred( "createGame", module, unitsCreationData )

	emit_signal("readyCompleted")


func _exit_tree():
	get_tree().paused = false
	Debug.updateVariable( "Pause", "Yes" if get_tree().paused else "No" )


func createGame( module : SavingModuleGd, unitsCreationData : Array ):
	_changeState( State.Creating )
	m_creator.call_deferred( "createFromModule", module, unitsCreationData )
	var result = yield( m_creator, "createFinished" )

	if result != OK:
		Debug.err(self, "GameScene: could not create game")
		finish()
	else:
		start()


func saveGame( filepath : String ):
	assert( m_state == State.Running )
	_changeState( State.Saving )
	m_module.saveLevel( m_currentLevel )
	m_module.savePlayerUnitPaths( m_currentLevel, m_playerManager.getPlayerUnitNodes() )
	var result = m_module.saveToFile( filepath )

	if result != OK:
		Debug.err( self, "Saving game to file %s failed." % filepath )
	_changeState( State.Running )


func loadGame( filepath : String ):
	assert( m_state in [State.Running, State.Initial] )
	var previousState = m_state
	_changeState( State.Creating )

	var result = yield( m_creator.createFromFile( filepath ), "completed" )

	start() if result == OK else _changeState( previousState )


func start():
	_changeState( State.Running )
	print( "-----\nGAME START\n-----" )
	emit_signal("gameStarted")


func finish():
	_changeState( State.Finished )


func loadLevel( levelName : String ) -> int:
	_changeState( State.Creating )
	var result = yield( m_creator.loadLevel( levelName, true ), "completed" )
	_changeState( State.Running )
	return result


func unloadCurrentLevel() -> int:
	_changeState( State.Creating )
	var result = yield( m_creator.unloadCurrentLevel(), "completed" )
	_changeState( State.Running )
	return result


func setCurrentModule( module : SavingModuleGd ):
	m_module = module


func setCurrentLevel( level : LevelBaseGd ):
	assert( level == null or m_currentLevelParent.is_a_parent_of( level ) )
	m_currentLevel = level


func setPause( paused : bool ):
	m_pause = paused
	updatePaused()


func updatePaused():
	get_tree().paused = m_pause or $"Pause/PlayerPause".m_pause
	Debug.updateVariable( "Pause", "Yes" if get_tree().paused else "No" )


func getPlayerUnitNodes():
	return m_playerManager.getPlayerUnitNodes()


func _changeState( state : int ):
	assert( m_state != State.Finished )

	if state == m_state:
		Debug.warn( self, "changing to same state: %s" % state )
		return

	if state == State.Finished:
		setPause(false)
		call_deferred( "emit_signal", "gameFinished" )

	elif state == State.Running:
		setPause(false)

	elif state == State.Creating:
		setPause(true)

	elif state == State.Saving:
		setPause(true)

	m_state = state

