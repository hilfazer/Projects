extends Node

const GameCreatorGd          = preload("./GameCreator.gd")
const SavingModuleGd         = preload("res://engine/SavingModule.gd")
const LevelLoaderGd          = preload("res://engine/game/LevelLoader.gd")

const PARAMS_META = "PARAMS"
enum Params { Module, PlayerUnitsData, SaveFileName }
enum State { Initial, Creating, Saving, Running, Finished }

var currentLevel : LevelBase           setget setCurrentLevel
var _module : SavingModuleGd           setget setCurrentModule
var _state : int = State.Initial       setget deleted # _changeState
var _pause := true                     setget setPause

onready var _creator : GameCreatorGd  = $"GameCreator"
onready var _playerManager            = $"PlayerManager"   setget deleted
onready var _playerAgent              = $"PlayerManager/PlayerAgent" setget deleted


signal gameStarted()
signal gameFinished()
signal currentLevelChanged( level )
signal nonmatchingSaveFileSelected( saveFile )


func deleted(_a):
	assert(false)


func _ready():
	_creator.initialize( self, self )

	_playerAgent.initialize( currentLevel )
	_playerAgent.connect("travelRequested", self, "_travel")

	var params = get_meta(PARAMS_META)
	set_meta(PARAMS_META, null)
	if params == null:
		return

	if !params.has( Params.Module ) && !params.has(Params.SaveFileName):
		Debug.error( self, "No module and no save file. Can't create game." )
		finish()
		return

	assert( !(params.has(Params.PlayerUnitsData) && params.has(Params.SaveFileName)) )

	# creating new game from module
	if params.has( Params.Module ):
		var module : SavingModuleGd = params[Params.Module]
		var unitsData = params[Params.PlayerUnitsData] \
			if params.has( Params.PlayerUnitsData ) \
			else []
		call_deferred( "createGame", module, unitsData )

	# creating game from save file
	elif params.has(Params.SaveFileName):
		call_deferred( "createGameFromFile", params[Params.SaveFileName] )
	else:
		Debug.error( self, "Can't create the game." )


func _exit_tree():
	get_tree().paused = false
	Debug.updateVariable( "Pause", "Yes" if get_tree().paused else "No" )


func createGame( module : SavingModuleGd, unitsCreationData : Array ):
	assert(module)
	_changeState( State.Creating )
	_creator.call_deferred( "createFromModule", module, unitsCreationData )
	var result = yield( _creator, "createFinished" )

	if result != OK:
		Debug.error(self, "GameScene: could not create game")
		finish()
	else:
		start()


func createGameFromFile( filePath : String ):
	assert(!_module)
	_changeState( State.Creating )
	var result = yield(_creator.createFromFile(filePath), "completed")

	if result != OK:
		Debug.error(self, "GameScene: could not create game from file %s" % filePath)
		finish()
	else:
		start()


func saveGame( filepath : String ):
	assert( _state == State.Running )
	_changeState( State.Saving )
	_module.saveLevel( currentLevel, true )
	_module.savePlayerData( _playerAgent )

	var result = _module.saveToFile( filepath )

	if result != OK:
		Debug.error( self, "Saving game to file %s failed." % filepath )
	_changeState( State.Running )


func loadGame( filepath : String ):
	assert( _state in [State.Running, State.Initial] )
	assert( _module )

	if not _module.moduleMatches(filepath):
		_changeState(State.Finished)
		emit_signal("nonmatchingSaveFileSelected", filepath)
		return

	var previousState = _state
	_changeState( State.Creating )

	var result = yield( _creator.createFromFile( filepath ), "completed" )

# warning-ignore:standalone_ternary
	start() if result == OK else _changeState( previousState )


func start():
	_changeState( State.Running )
	Debug.info( self, "-----\nGAME START\n-----" )
	emit_signal("gameStarted")


func finish():
	_changeState( State.Finished )
	emit_signal( "gameFinished" )


func loadLevel( levelName : String ) -> int:
	if currentLevel:
		_changeState( State.Saving )
		_playerManager.unparentUnits()
		_module.saveLevel( currentLevel, false )

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
	if level == currentLevel:
		return

	assert( level == null or self.is_a_parent_of( level ) )
	currentLevel = level
	_playerAgent.setCurrentLevel(level)
	emit_signal("currentLevelChanged", level)


func setPause( paused : bool ):
	_pause = paused
	updatePaused()


func updatePaused():
	get_tree().paused = _pause or $"Pause/PlayerPause"._pause
	Debug.updateVariable( "Pause", "Yes" if get_tree().paused else "No" )


func getPlayerUnits():
	return _playerAgent.getUnits()


func _travel( entrance : Area2D ):
	var levelAndEntranceNames : PoolStringArray = _module.getTargetLevelFilenameAndEntrance(
	currentLevel.name, entrance.name )

	if levelAndEntranceNames.empty():
		return

	_changeState( State.Creating )

	var levelName : String = levelAndEntranceNames[0].get_file().get_basename()
	var entranceName : String = levelAndEntranceNames[1]
	var result : int = yield( loadLevel( levelName ), "completed" )

	if result != OK:
		return

	_playerAgent.set_physics_process(false)

	var notAdded = LevelLoaderGd.insertPlayerUnits(
			_playerAgent.getUnits(), currentLevel, entranceName )

	# TODO: replace it with _changeState( State.Running ) that unpauses the game
	# but first remove that from GameScene.loadLevel()
	yield(get_tree(), "idle_frame")
	_playerAgent.set_physics_process(true)


	for unit in notAdded:
		Debug.info(self, "Unit '%s' not added to level" % unit.name)


func _changeState( state : int ):
	assert( _state != State.Finished )

	if state == _state:
		Debug.warn( self, "changing to same state: %s" % state )
		return

	if state == State.Finished:
		setPause(false)

	elif state == State.Running:
		setPause(false)

	elif state == State.Creating:
		setPause(true)

	elif state == State.Saving:
		setPause(true)

	_state = state
