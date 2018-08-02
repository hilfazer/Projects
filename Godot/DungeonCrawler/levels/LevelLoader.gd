extends Reference

const GameSceneGd            = preload("res://game/GameScene.gd")
const Global                 = preload("res://GlobalNames.gd")
const UtilityGd              = preload("res://Utility.gd")

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
	yield( game.m_currentLevel, "predelete" )
	game.setCurrentLevel( null )
	emit_signal( "levelUnloaded", levelName )


func insertPlayerUnits( playerUnits, level, entranceName ):
	var spawns = getSpawnsFromEntrance( level, entranceName )

	var spawnIdx = 0
	for unit in playerUnits:
		assert( unit[GameSceneGd.OWNER] in Network.m_clients )

		var freeSpawn = findFreePlayerSpawn( spawns )
		if freeSpawn == null:
			continue

		spawns.erase(freeSpawn)
		var unitNode = unit[GameSceneGd.NODE]
		level.get_node("Units").add_child( unitNode, true )
		unitNode.set_position( freeSpawn.global_position )
		spawnIdx += 1
		
		
func getSpawnsFromEntrance( level, entranceName ):
	var spawns = []
	var entranceNode

	if entranceName == null:
		UtilityGd.log("Level entrance name unspecified. Using first entrance found.")
		entranceNode = level.get_node("Entrances").get_child(0)
	else:
		entranceNode = level.get_node("Entrances/" + entranceName)
		if entranceNode == null:
			UtilityGd.log("Level entrance name not found. Using first entrance found.")
			entranceNode = level.get_node("Entrances").get_child(0)

	assert( entranceNode != null )
	for child in entranceNode.get_children():
		if child.is_in_group( Global.Groups.SpawnPoints ):
			spawns.append( child )

	return spawns


func findFreePlayerSpawn( spawns ):
	for spawn in spawns:
		if spawn.spawnAllowed():
			return spawn

	return null
