extends Node

const GameCreatorGd          = preload("./GameCreator.gd")
const SavingModuleGd         = preload("res://core/SavingModule.gd")

enum Params { Module, PlayerUnitsData }
enum State { Initial, Creating, Saving, Running, Finished }

var _module : SavingModuleGd           setget setCurrentModule
var _currentLevel : LevelBase        setget setCurrentLevel
var _state : int = State.Initial       setget deleted # _changeState
var _pause := true                     setget setPause

onready var _creator : GameCreatorGd  = $"GameCreator"
onready var _currentLevelParent       = $"GameWorldView/Viewport"
onready var _playerManager            = $"PlayerManager"   setget deleted


signal readyCompleted()
signal gameStarted()
signal gameFinished()


func deleted(_a):
	assert(false)


func _ready():
	_creator.initialize( self )

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
	_creator.call_deferred( "createFromModule", module, unitsCreationData )
	var result = yield( _creator, "createFinished" )

	if result != OK:
		Debug.err(self, "GameScene: could not create game")
		finish()
	else:
		start()


func saveGame( filepath : String ):
	assert( _state == State.Running )
	_changeState( State.Saving )
	_module.saveLevel( _currentLevel )
	_module.savePlayerUnitPaths( _currentLevel, _playerManager.getPlayerUnitNodes() )
	var result = _module.saveToFile( filepath )

	if result != OK:
		Debug.err( self, "Saving game to file %s failed." % filepath )
	_changeState( State.Running )


func loadGame( filepath : String ):
	assert( _state in [State.Running, State.Initial] )
	var previousState = _state
	_changeState( State.Creating )

	var result = yield( _creator.createFromFile( filepath ), "completed" )

	start() if result == OK else _changeState( previousState )


func start():
	_changeState( State.Running )
	print( "-----\nGAME START\n-----" )
	emit_signal("gameStarted")


func finish():
	_changeState( State.Finished )


func loadLevel( levelName : String ) -> int:
	_changeState( State.Creating )
	var result = yield( _creator.loadLevel( levelName, true ), "completed" )
	_changeState( State.Running )
	return result


func unloadCurrentLevel() -> int:
	_changeState( State.Creating )
	var result = yield( _creator.unloadCurrentLevel(), "completed" )
	_changeState( State.Running )
	return result


func setCurrentModule( module : SavingModuleGd ):
	_module = module


func setCurrentLevel( level : LevelBase ):
	assert( level == null or _currentLevelParent.is_a_parent_of( level ) )
	_currentLevel = level


func setPause( paused : bool ):
	_pause = paused
	updatePaused()


func updatePaused():
	get_tree().paused = _pause or $"Pause/PlayerPause"._pause
	Debug.updateVariable( "Pause", "Yes" if get_tree().paused else "No" )


func getPlayerUnitNodes():
	return _playerManager.getPlayerUnitNodes()


func _changeState( state : int ):
	assert( _state != State.Finished )

	if state == _state:
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

	_state = state

