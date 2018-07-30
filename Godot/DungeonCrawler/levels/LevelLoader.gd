extends Reference

const GameSceneGd = preload("res://game/GameScene.gd")
const Global = preload("res://GlobalNames.gd")
const PlayerSpawnsGroup = "PlayerSpawns"

signal levelLoaded( nodeName )
signal levelUnloaded( nodeName )


func loadLevel( levelFilename, game ):
	assert( game is GameSceneGd )
	var level = load( levelFilename )
	if not level:
		print( "ERROR: could not load level file: " + levelFilename )
	level = level.instance()

	if game.m_currentLevel == null:
		assert( not game.has_node( level.name ) )
		game.add_child( level )
		game.setCurrentLevel( level )
	else:
		unloadLevel( game )
		yield( self, "levelUnloaded" )
		assert( not game.has_node( level.name ) )
		game.add_child( level )
		game.setCurrentLevel( level )

	emit_signal( "levelLoaded", level.name )


func unloadLevel( game ):
	assert( game is GameSceneGd )
	assert( game.m_currentLevel )
	# take player units from level
	for playerUnit in game.m_playerUnits:
		game.m_currentLevel.removeChildUnit( playerUnit[GameSceneGd.NODE] )

	game.m_currentLevel.queue_free()
	var levelName = game.m_currentLevel.name
	yield( game.m_currentLevel, "destroyed" )
	game.setCurrentLevel( null )
	emit_signal( "levelUnloaded", levelName )


func insertPlayerUnits(playerUnits, level):
	var spawns = level.get_tree().get_nodes_in_group( Global.Groups.SpawnPoints )

	var spawnIdx = 0
	for unit in playerUnits:
		assert( unit[GameSceneGd.OWNER] in Network.m_players )

		var freeSpawn = findFreePlayerSpawn( spawns )
		if freeSpawn == null:
			continue

		spawns.erase(freeSpawn)
		var unitNode = unit[GameSceneGd.NODE]
		level.get_node("Units").add_child( unitNode, true )
		unitNode.set_position( freeSpawn.global_position )
		spawnIdx += 1


func findFreePlayerSpawn( spawns ):
	for spawn in spawns:
		if spawn.spawnAllowed():
			return spawn

	return null
