extends Reference

const GameSceneGd = preload("res://game/GameScene.gd")

const PlayerSpawnsGroup = "PlayerSpawns"


func loadLevel( levelFilename, game ):
	var level = load( levelFilename )
	if not level:
		print( "ERROR: could not load level file: " + levelFilename )
	level = level.instance()

	if game.m_currentLevel == null:
		assert( not game.has_node( level.name ) )
		game.add_child( level )
		game.setCurrentLevel( level )
	else:
		unloadLevel( game.m_currentLevel )
		yield( self, "levelUnloaded" )
		assert( not game.has_node( level.name ) )
		game.add_child( level )
		game.setCurrentLevel( level )

	emit_signal( "levelLoaded", level.name )

signal levelLoaded( nodeName )


func unloadLevel( game ):
	assert( game.m_currentLevel )
	# take player units from level
	for playerUnit in game.m_playerUnits:
		game.m_currentLevel.removeChildUnit( playerUnit[GameSceneGd.NODE] )

	game.m_currentLevel.queue_free()
	var levelName = game.m_currentLevel.name
	yield( game.m_currentLevel, "destroyed" )
	game.setCurrentLevel( null )
	emit_signal( "levelUnloaded", levelName )

signal levelUnloaded( nodeName )


func insertPlayerUnits(playerUnits, level):
	var spawns = level.get_tree().get_nodes_in_group(PlayerSpawnsGroup)

	var spawnIdx = 0
	for unit in playerUnits:
		assert( unit[GameSceneGd.OWNER] in Network.m_players )

		var freeSpawn = findFreePlayerSpawn( spawns )
		if freeSpawn == null:
			continue

		spawns.erase(freeSpawn)
		var unitNode = unit[GameSceneGd.NODE]
		level.get_node("Units").add_child( unitNode, true )
		unitNode.set_position( freeSpawn.get_position() )
		spawnIdx += 1


func findFreePlayerSpawn( spawns ):
	for spawn in spawns:
		if spawn.spawnAllowed():
			return spawn

	return null
