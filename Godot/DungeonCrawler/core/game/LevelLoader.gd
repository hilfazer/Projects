extends Reference

const GlobalGd               = preload("res://core/GlobalNames.gd")
const LevelBaseGd            = preload("res://core/level/LevelBase.gd")
const UtilityGd              = preload("res://core/Utility.gd")

enum State { Ready, Adding, Removing }

var m_game : Node                      setget deleted
var m_levelFilename : String           setget deleted
var m_state : int = State.Ready        setget deleted


func deleted(_a):
	assert(false)


func _init( game : Node ):
	m_game = game


func loadLevel( levelFilename : String, levelParent : Node ):
	assert( m_game.m_state == m_game.State.Creating )
	assert( m_game.is_a_parent_of( levelParent ) )
	yield( m_game.get_tree(), "idle_frame" )

	if m_state != State.Ready:
		Debug.warn(self, "LevelLoader not ready to load %s" % levelFilename)
		return ERR_UNAVAILABLE

	var level = load( levelFilename )
	if not level:
		Debug.err( self, "Could not load level file: " + levelFilename )
		return ERR_CANT_CREATE

	var revertState = UtilityGd.scopeExit( self, "_changeState", [m_state, m_levelFilename] )
	_changeState( State.Adding, levelFilename )

	level = level.instance()

	if m_game.m_currentLevel != null:
		var result = yield( unloadLevel(), "completed" )
		assert( result == OK )

	assert( not m_game.has_node( level.name ) )
	levelParent.add_child( level )
	m_game.setCurrentLevel( level )

	assert( level.is_inside_tree() )
	assert( m_game.m_currentLevel == level )
	return OK


func unloadLevel() -> int:
	assert( m_game.m_currentLevel )
	yield( m_game.get_tree(), "idle_frame" )
	if( not m_state in [State.Ready, State.Adding] ):
		return ERR_UNAVAILABLE

	var revertState = UtilityGd.scopeExit( self, "_changeState", [m_state, m_levelFilename] )
	_changeState( State.Removing, m_game.m_currentLevel.name )

	# take player units from level
	for playerUnit in m_game.getPlayerUnits():
		m_game.m_currentLevel.removeChildUnit( playerUnit )

	m_game.m_currentLevel.queue_free()
	var levelName = m_game.m_currentLevel.name
	yield( m_game.m_currentLevel, "predelete" )
	m_game.setCurrentLevel( null )
	return OK


func insertPlayerUnits( playerUnits, level : LevelBaseGd, entranceName : String ):
	var spawns = getSpawnsFromEntrance( level, entranceName )

	for unit in playerUnits:
		var freeSpawn = findFreePlayerSpawn( spawns )
		if freeSpawn == null:
			continue

		spawns.erase(freeSpawn)
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
		m_state:
			Debug.warn(self, "changing to same state")
			return
		State.Ready:
			assert( levelFilename.empty() )
		State.Adding:
			assert( not levelFilename.empty() )
		State.Removing:
			assert( not levelFilename.empty() )

	m_levelFilename = levelFilename
	m_state = state
