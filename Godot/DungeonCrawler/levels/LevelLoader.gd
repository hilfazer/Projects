extends Node

const DwarfScn = preload("res://units/Dwarf.tscn")
const PlayerAgentGd = preload("res://actors/PlayerAgent.gd")
const UnitGd = preload("res://units/unit.gd")

const PlayerSpawnsGroup = "PlayerSpawns"

var m_loadedLevel  setget deleted


func deleted():
	assert(false)


slave func loadLevel(levelFilename, parentNodePath, name):
	assert(parentNodePath != null)
	var level = load(levelFilename).instance()
	get_node(parentNodePath).add_child(level)
	level.set_name(name)
	m_loadedLevel = level
	return level


func unloadLevel(level):
	if (level != null):
		level.set_pause_mode(true)
		level.queue_free()


sync func insertPlayers(players):
	assert(m_loadedLevel != null)
	var spawns = m_loadedLevel.get_tree().get_nodes_in_group(PlayerSpawnsGroup)
	
	var spawnIdx = 0
	for pid in players:
		if m_loadedLevel.get_node("Units").has_node( str(pid) ):
			continue

		if (not pid in gamestate.m_players):
			continue

		if spawnIdx >= spawns.size():
			break

		var freeSpawn = findFreePlayerSpawn( spawns )
		if freeSpawn == null:
			continue

		spawns.erase(freeSpawn)
		var dwarf = DwarfScn.instance()
		dwarf.set_position( freeSpawn.get_position() )
		dwarf.set_name(str(pid))
		dwarf.get_node(UnitGd.UnitNameLabel).text = players[pid]
		m_loadedLevel.get_node("Units").add_child(dwarf)

		if(pid == m_loadedLevel.get_tree().get_network_unique_id()):
			var playerAgent = Node.new()
			playerAgent.set_network_master(pid)
			playerAgent.set_script(PlayerAgentGd)
			playerAgent.setActions(PlayerAgentGd.PlayersActions[0])
			playerAgent.assignToUnit(dwarf)
		
		spawnIdx += 1
		
		
func findFreePlayerSpawn( spawns ):
	for spawn in spawns:
		if spawn.spawnAllowed():
			return spawn

	return null


func sendToClient(clientId, parentNodePath, name):
	assert(get_tree().is_network_server())
	assert(m_loadedLevel != null)
	var levelFilename = m_loadedLevel.get_filename()
	rpc_id(clientId, "loadLevel", levelFilename, parentNodePath, name)
	m_loadedLevel.sendToClient(clientId)
	rpc_id(clientId, "levelLoadingComplete")


func saveGame(filePath):
	var saveDict = {}
	saveDict[m_loadedLevel.get_name()] = m_loadedLevel.save()

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
	gamestate.rpc("registerPlayer", get_tree().get_network_unique_id(), \
		gamestate.m_playerName)
	gamestate.rpc_id(gamestate.SERVER_ID, "addRegisteredPlayerToGame", \
		get_tree().get_network_unique_id() )
	
	