extends Node

const GameCreatorGd          = preload("./GameCreator.gd")
const SavingModuleGd         = preload("res://core/SavingModule.gd")
const LevelBaseGd            = preload("res://core/level/LevelBase.gd")

enum Params { Module, PlayerUnitsData }
enum State { Initial, Creating, Running, Finished }

var m_module : SavingModuleGd          setget setCurrentModule
var m_currentLevel : LevelBaseGd       setget setCurrentLevel
var m_state : int = State.Initial      setget deleted # _changeState

onready var m_creator : GameCreatorGd  = $"GameCreator"
onready var m_currentLevelParent       = $"GameWorldView/Viewport"


signal readyCompleted()
signal gameStarted()
signal gameFinished()


func deleted(_a):
	assert(false)


func _ready():
	m_creator.initialize( self )

	var params = SceneSwitcher.getParams()
	if params == null:
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


func createGame( module : SavingModuleGd, unitsCreationData : Array ):
	_changeState( State.Creating )
	m_creator.call_deferred( "createFromModule", module, unitsCreationData )
	var result = yield( m_creator, "createFinished" )

	if result != OK:
		Debug.err(self, "GameScene: could not create game")
		finish()
	else:
		start()


func start():
	_changeState( State.Running )
	print( "-----\nGAME START\n-----" )
	emit_signal("gameStarted")


func finish():
	_changeState( State.Finished )


func setCurrentModule( module : SavingModuleGd ):
	m_module = module


func setCurrentLevel( level : LevelBaseGd ):
	assert( level == null or m_currentLevelParent.is_a_parent_of( level ) )
	m_currentLevel = level


func setPaused( enabled : bool ):
	get_tree().paused = enabled
	Debug.updateVariable( "Pause", "Yes" if get_tree().paused else "No" )


func _changeState( state : int ):
	assert( m_state != State.Finished )

	if state == m_state:
		Debug.warn(self, "changing to same state")
		return

	if state == State.Finished:
		setPaused(false)
		call_deferred( "emit_signal", "gameFinished" )

	elif state == State.Running:
		setPaused(false)

	elif state == State.Creating:
		setPaused(true)

	m_state = state

