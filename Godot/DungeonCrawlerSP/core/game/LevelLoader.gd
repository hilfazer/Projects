extends Reference

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
		Debug.error( self, "Could not load level file: " + levelFilename )
		return ERR_CANT_CREATE

	var revertState = Utility.scopeExit( self, "_changeState", [_state, _levelFilename] )
	_changeState( State.Adding, levelFilename )

	level = level.instance()

	if _game.currentLevel != null:
		var result = yield( unloadLevel(), "completed" )
		assert( result == OK )

	assert( not _game.has_node( level.name ) )
	levelParent.add_child( level )
	_game.setCurrentLevel( level )

	assert( level.is_inside_tree() )
	assert( _game.currentLevel == level )
	return OK


func unloadLevel() -> int:
	assert( _game.currentLevel )
	yield( _game.get_tree(), "idle_frame" )
	if( not _state in [State.Ready, State.Adding] ):
		return ERR_UNAVAILABLE

	var revertState = Utility.scopeExit( self, "_changeState", [_state, _levelFilename] )
	_changeState( State.Removing, _game.currentLevel.name )

	# take player units from level
	for playerUnit in _game.getPlayerUnitNodes():
		_game.currentLevel.removeChildUnit( playerUnit )

	_game.currentLevel.queue_free()
	var levelName = _game.currentLevel.name
	yield( _game.currentLevel, "predelete" )
	yield( _game.get_tree(), "idle_frame" )
	assert( not is_instance_valid( _game.currentLevel ) )
	_game.setCurrentLevel( null )
	return OK


static func insertPlayerUnits( playerUnits : Array, level : LevelBase, entranceName : String ):
	var spawns = getSpawnsFromEntrance( level, entranceName )

	for unit in playerUnits:
		assert( unit is UnitBase and is_instance_valid( unit ) )
		var freeSpawn = findFreePlayerSpawn( spawns )
		if freeSpawn == null:
			continue

		spawns.erase( freeSpawn )
		unit.set_position( freeSpawn.global_position )
		level.get_node("Units").add_child( unit, true )


static func getSpawnsFromEntrance( level : LevelBase, entranceName : String ) -> Array:
	var spawns = []
	var entranceNode

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
		if child.is_in_group( GlobalNames.Groups.SpawnPoints ):
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
		State.Adding:
			assert( not levelFilename.empty() )
		State.Removing:
			assert( not levelFilename.empty() )

	_levelFilename = levelFilename
	_state = state
