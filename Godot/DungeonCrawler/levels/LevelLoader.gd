extends Reference

const UnitGd = preload("res://units/unit.gd")
const GameGd = preload("res://game/Game.gd")

const PlayerSpawnsGroup = "PlayerSpawns"


func loadLevel(levelFilename, parentNode):
	assert(parentNode != null)
	var level = load(levelFilename).instance()
	parentNode.add_child(level)
	return level


func unloadLevel(level):
	if (level != null):
		level.set_pause_mode(true)
		level.queue_free()


func insertPlayerUnits(playerUnits, level):
	var spawns = level.get_tree().get_nodes_in_group(PlayerSpawnsGroup)

	var spawnIdx = 0
	for unit in playerUnits:
		assert( unit[GameGd.OWNER] in Network.m_players )

		var freeSpawn = findFreePlayerSpawn( spawns )
		if freeSpawn == null:
			continue

		spawns.erase(freeSpawn)
		var unitNode = unit[GameGd.NODE]
		level.get_node("Units").add_child( unitNode, true )
		unitNode.set_position( freeSpawn.get_position() )
		spawnIdx += 1


func findFreePlayerSpawn( spawns ):
	for spawn in spawns:
		if spawn.spawnAllowed():
			return spawn

	return null


func sendToClient(clientId, level):
	assert(Network.isServer())
	rpc_id(clientId, "loadLevel",
		level.get_filename(), level.get_parent().get_path(), level.get_name() )
	level.sendToClient(clientId)
	rpc_id(clientId, "levelLoadingComplete")


func saveGame(filePath, level):
	var saveDict = {}
	saveDict[level.get_name()] = level.save()

	var saveFile = File.new()
	saveFile.open(filePath, File.WRITE)

	saveFile.store_line(to_json(saveDict))
	saveFile.close()


func loadGame(saveFilePath, levelParentNodePath):
	var saveFile = File.new()
	if not saveFile.file_exists(saveFilePath):
		return

	saveFile.open(saveFilePath, File.READ)
	var gameStateDict = parse_json(saveFile.get_as_text())

	var levelDict = gameStateDict.values()[0]
	var level = loadLevel( levelDict.scene, levelParentNodePath, gameStateDict.keys()[0] )
	level.load(levelDict)


slave func levelLoadingComplete():
	Network.rpc("registerPlayer", get_tree().get_network_unique_id(), \
		Network.m_playerName)
	Network.rpc_id(Network.SERVER_ID, "addRegisteredPlayerToGame", \
		get_tree().get_network_unique_id() )
