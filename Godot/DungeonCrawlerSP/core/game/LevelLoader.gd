extends Reference

const GlobalGd               = preload("res://core/GlobalNames.gd")
const LevelBaseGd            = preload("res://core/level/LevelBase.gd")
const UtilityGd              = preload("res://core/Utility.gd")

enum State { Ready, Adding, Removing }

var _game : Node                       setget deleted
var _levelFilename : String            setget deleted
var _state : int = State.Ready         setget deleted


func deleted(_a):
	assert(false)


func _init( game : Node ):
	_game = game


func loadLevel( levelFilename : String, levelParent : Node ):
	assert( _game._state == _game.State.Creating )
	assert( _game.is_a_parent_of( levelParent ) )
	yield( _game.get_tree(), "idle_frame" )

	if _state != State.Ready:
		Debug.warn(self, "LevelLoader not ready to load %s" % levelFilename)
		return ERR_UNAVAILABLE

	var level = load( levelFilename )
	if not level:
		Debug.err( self, "Could not load level file: " + levelFilename )
		return ERR_CANT_CREATE

	var revertState = UtilityGd.scopeExit( self, "_changeState", [_state, _levelFilename] )
	_changeState( State.Adding, levelFilename )

	level = level.instance()

	if _game._currentLevel != null:
		var result = yield( unloadLevel(), "completed" )
		assert( result == OK )

	assert( not _game.has_node( level.name ) )
	levelParent.add_child( level )
	_game.setCurrentLevel( level )

	assert( level.is_inside_tree() )
	assert( _game._currentLevel == level )
	return OK


func unloadLevel() -> int:
	assert( _game._currentLevel )
	yield( _game.get_tree(), "idle_frame" )
	if( not _state in [State.Ready, State.Adding] ):
		return ERR_UNAVAILABLE

	var revertState = UtilityGd.scopeExit( self, "_changeState", [_state, _levelFilename] )
	_changeState( State.Removing, _game._currentLevel.name )

	# take player units from level
	for playerUnit in _game.getPlayerUnitNodes():
		_game._currentLevel.removeChildUnit( playerUnit )

	_game._currentLevel.queue_free()
	var levelName = _game._currentLevel.name
	yield( _game._currentLevel, "predelete" )
	_game.setCurrentLevel( null )
	return OK


func insertPlayerUnits( playerUnits, level : LevelBaseGd, entranceName : String ):
	var spawns = getSpawnsFromEntrance( level, entranceName )

	for unit in playerUnits:
		var freeSpawn = findFreePlayerSpawn( spawns )
		if freeSpawn == null:
			continue

		spawns.erase( freeSpawn )
		level.get_node("Units").add_child( unit, true )
		unit.set_position( freeSpawn.global_position )


func getSpawnsFromEntrance( level : LevelBaseGd, entranceName : String ) -> Array:
	var spawns = []
	var entranceNode

	if entranceName == null:
		Debug.info(self, "Level entrance name unspecified. Using first entrance found.")
		entranceNode = level.get_node("Entrances").get_child(0)
	else:
		entranceNode = level.get_node("Entrances/" + entranceName)
		if entranceNode == null:
			Debug.warn(self, "Level entrance name not found. Using first entrance found.")
			entranceNode = level.get_node("Entrances").get_child(0)

	assert( entranceNode != null )
	for child in entranceNode.get_children():
		if child.is_in_group( GlobalGd.Groups.SpawnPoints ):
			spawns.append( child )

	return spawns


func findFreePlayerSpawn( spawns : Array ):
	for spawn in spawns:
		if spawn.spawnAllowed():
			return spawn

	return null


func _changeState( state : int, levelFilename : String = "" ):
	match( state ):
		_state:
			Debug.warn(self, "changing to same state")
			return
		State.Ready:
			assert( levelFilename.empty() )
		State.Adding:
			assert( not levelFilename.empty() )
		State.Removing:
			assert( not levelFilename.empty() )

	_levelFilename = levelFilename
	_state = state
