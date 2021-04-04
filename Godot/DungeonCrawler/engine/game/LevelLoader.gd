extends Reference

enum State { Ready, Loading, Unloading }

var _game : Node                       setget deleted
var _levelFilename : String            setget deleted
var _state : int = State.Ready         setget deleted


func deleted(_a):
	assert(false)


func _init( game : Node ):
	_game = game


func loadLevel( levelFilename : String, levelParent : Node ) -> int:
	assert( _game._state == _game.State.Creating )
	assert( _game.is_a_parent_of( levelParent ) or _game == levelParent )

	if _state != State.Ready:
		Debug.warn(self, "LevelLoader not ready to load %s" % levelFilename)
		return ERR_UNAVAILABLE

	_changeState(State.Loading, levelFilename)
	var retval = yield(_loadLevel(levelFilename, levelParent), "completed")
	_changeState(State.Ready)
	return retval


func _loadLevel( levelFilename : String, levelParent : Node ) -> int:
	yield( _game.get_tree(), "idle_frame" )
	var levelResource = load( levelFilename )
	if not levelResource:
		Debug.error( self, "Could not load level file: " + levelFilename )
		return ERR_CANT_CREATE

	var level : LevelBase = levelResource.instance()

	if _game.currentLevel != null:
		var result = yield( _unloadLevel(_game.currentLevel), "completed" )
		assert( result == OK )

	assert( not _game.has_node( level.name ) )
	levelParent.add_child( level )
	_game.setCurrentLevel( level )

	assert( level.is_inside_tree() )
	assert( _game.currentLevel == level )
	return OK


func unloadLevel() -> int:
	if( not _state == State.Ready ):
		return ERR_UNAVAILABLE

	assert( _game.currentLevel )
	var level : LevelBase = _game.currentLevel

	_changeState( State.Unloading, level.name )
	var retval : int = yield(_unloadLevel(level), "completed")
	_changeState( State.Ready )
	return retval


func _unloadLevel( level : LevelBase ) -> int:
	yield( _game.get_tree(), "idle_frame" )
	var levelUnits = level.getAllUnits()
	for playerUnit in _game.getPlayerUnits():
		if playerUnit in levelUnits:
			Debug.info( self, "Player unit '%s' will be destroyed with level '%s'" %
				[ playerUnit.name, level.name ] )

	level.queue_free()
	yield( level, "predelete" )
	yield( _game.get_tree(), "idle_frame" )
	assert( not is_instance_valid( level ) )
	_game.setCurrentLevel( null )
	return OK


static func insertPlayerUnits( \
		playerUnits : Array, level : LevelBase, entranceName : String ) -> Array:

	var spawns = getSpawnsFromEntrance( level, entranceName )
	var notAdded := []

	for unit in playerUnits:
		assert( unit is UnitBase and is_instance_valid(unit) )
		var freeSpawn = findFreePlayerSpawn(spawns)
		if freeSpawn == null:
			continue

		spawns.erase(freeSpawn)
		unit.set_position(freeSpawn.global_position)
		var added = level.addUnit(unit) == OK
		if not added:
			notAdded.append(unit)

	return notAdded


static func getSpawnsFromEntrance( level : LevelBase, entranceName : String ) -> Array:
	var spawns := []
	var entranceNode : Node

	if entranceName == null:
		Debug.info(level, "Level entrance name unspecified. Using first entrance found.")
		entranceNode = level.get_node("Entrances").get_child(0)
	else:
		entranceNode = level.get_node("Entrances/" + entranceName)
		if entranceNode == null:
			Debug.warn(level, "Level entrance name not found. Using first entrance found.")
			entranceNode = level.get_node("Entrances").get_child(0)

	assert( entranceNode != null )
	for child in entranceNode.get_children():
		if child.is_in_group( Globals.Groups.SpawnPoints ):
			spawns.append( child )

	return spawns


static func findFreePlayerSpawn( spawns : Array ):
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
		State.Loading:
			assert( not levelFilename.empty() )
		State.Unloading:
			assert( not levelFilename.empty() )

	_levelFilename = levelFilename
	_state = state
