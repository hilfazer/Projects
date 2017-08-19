extends Node

const DwarfScn = preload("res://units/Dwarf.tscn")
const PlayerAgentGd = preload("res://actors/PlayerAgent.gd")

const PlayerSpawnsGroup = "PlayerSpawns"

var m_loadedLevel  setget deleted


func deleted():
	assert(false)


remote func loadLevel(levelFilename):
	unloadLevel()
	var level = load(levelFilename).instance()
	get_tree().get_root().add_child(level)
	m_loadedLevel = level
	
	
func unloadLevel():
	if (m_loadedLevel != null):
		m_loadedLevel.queue_free()
		m_loadedLevel = null
	
	
func insertPlayers(players):
	assert(m_loadedLevel != null)
	var spawns = m_loadedLevel.get_tree().get_nodes_in_group(PlayerSpawnsGroup)
	
	var spawnIdx = 0
	for pid in players:
		if spawnIdx >= spawns.size():
			break

		var dwarf = DwarfScn.instance()
		dwarf.set_position( spawns[spawnIdx].get_position() )
		dwarf.set_name(str(pid))
		var nameLabel = Label.new()
		nameLabel.text = players[pid]
		dwarf.add_child(nameLabel)
		m_loadedLevel.add_child(dwarf)

		if(pid == m_loadedLevel.get_tree().get_network_unique_id()):
			var playerAgent = Node.new()
			playerAgent.set_network_master(pid)
			playerAgent.set_script(PlayerAgentGd)
			playerAgent.setActions(PlayerAgentGd.PlayersActions[0])
			playerAgent.assignToUnit(dwarf)
		
		spawnIdx += 1
	
	
func sendLevelToPlayer(playerId):
	assert(m_loadedLevel != null)
	var levelFilename = m_loadedLevel.get_filename()
	rpc_id(playerId, "loadLevel", levelFilename)
	m_loadedLevel.sendToPlayer(playerId)
