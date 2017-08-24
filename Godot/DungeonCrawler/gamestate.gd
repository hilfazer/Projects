extends Node

const WorldPath = "res://levels/World.tscn"
const LevelLoaderGd = preload("res://levels/LevelLoader.gd")

const DEFAULT_PORT = 10567
const MAX_PEERS = 12

var m_playerName = "Player"  setget deleted
# Names for remote players, including host, in id:name format
var m_players = {}           setget deleted
var m_playersReady = []

# Signals to let lobby GUI know what's going on
signal playerListChanged()
signal connectionFailed()
signal connectionSucceeded()
signal gameEnded()
signal gameError(what)
signal sendVariable(name, value)
signal networkPeerChanged()


func deleted():
	assert(false)
	
func _ready():
	get_tree().connect("network_peer_connected", self, "playerConnected")
	get_tree().connect("network_peer_disconnected", self,"playerDisconnected")
	get_tree().connect("connected_to_server", self, "connectedOk")
	get_tree().connect("connection_failed", self, "connectedFail")
	get_tree().connect("server_disconnected", self, "serverDisconnected")

	var levelLoaderNode = Node.new()
	levelLoaderNode.set_name("LevelLoader")
	levelLoaderNode.set_script( LevelLoaderGd )
	add_child(levelLoaderNode)


func playerConnected(id):
	if (not get_tree().is_network_server() or not isGameInProgress()):
		return

	get_node("LevelLoader").sendToClient(id)


func playerDisconnected(id):
	unregister_player(id)
	for p_id in m_players:
		if p_id != get_tree().get_network_unique_id():
			rpc_id(p_id, "unregister_player", id)


func connectedOk():
	assert(not get_tree().is_network_server())
	# Registration of a client beings here, tell everyone that we are here
	rpc("registerPlayer", get_tree().get_network_unique_id(), m_playerName)
	registerPlayer(get_tree().get_network_unique_id(), m_playerName)
	emit_signal("connectionSucceeded")


func serverDisconnected():
	assert(not get_tree().is_network_server())
	emit_signal("gameError", "Server disconnected")
	endGame()


func connectedFail():
	assert(not get_tree().is_network_server())
	get_tree().set_network_peer(null) # Remove peer
	emit_signal("connectionFailed")

# Lobby management functions

remote func registerPlayer(id, name):
	if (get_tree().is_network_server()):
		rpc("registerPlayer", id, name)
		for p_id in m_players:
			rpc_id(id, "registerPlayer", p_id, m_players[p_id]) # Send player to new dude

	m_players[id] = name
	emit_signal("playerListChanged")

remote func unregister_player(id):
	m_players.erase(id)
	emit_signal("playerListChanged")


remote func readyToStart(id):
	assert(get_tree().is_network_server())

	if (not id in m_playersReady):
		m_playersReady.append(id)

	if (m_playersReady.size() == m_players.size()):
		for p in m_players:
			rpc_id(p, "postStartGame")
		postStartGame()


func hostGame(name):
	m_playerName = name
	var host = NetworkedMultiplayerENet.new()
	host.create_server(DEFAULT_PORT, MAX_PEERS)
	setNetworkPeer(host)


func joinGame(ip, name):
	m_playerName = name
	if (get_tree().is_network_server()):
		registerPlayer(get_tree().get_network_unique_id(), m_playerName)
		return

	var host = NetworkedMultiplayerENet.new()
	host.create_client(ip, DEFAULT_PORT)
	setNetworkPeer(host)


func beginGame():
	assert(get_tree().is_network_server())
	rpc("preStartGame", m_players)


sync func preStartGame(playersOnServer):
	get_node("LevelLoader").loadLevel(WorldPath)
	get_node("LevelLoader").insertPlayers(playersOnServer)
	get_node("LevelLoader").m_loadedLevel.setGroundTile("Statue", 4, 4)

	if (not get_tree().is_network_server()):
		# Tell server we are ready to start
		rpc_id(1, "readyToStart", get_tree().get_network_unique_id())
	elif m_players.size() == 0:
		postStartGame()


remote func postStartGame():
	get_tree().set_pause(false) # Unpause and unleash the game!


func endGame():
	if (isGameInProgress()):
		get_node("LevelLoader").unloadLevel()

	emit_signal("gameEnded")
	m_players.clear()
	emit_signal("playerListChanged")
	setNetworkPeer(null)


func isGameInProgress():
	return get_node("LevelLoader").m_loadedLevel != null
	
	
func setNetworkPeer(host):
	get_tree().set_network_peer(host)
	
	var peerId = str(host.get_instance_ID()) if get_tree().has_network_peer() else null
	if peerId != null and get_tree().is_network_server():
		peerId += " (server)" 
	emit_signal("sendVariable", "network_host_ID", peerId )
	emit_signal("networkPeerChanged")
	

remote func addRegisteredPlayerToGame(id):
	if id in m_players:
		get_node("LevelLoader").rpc( "insertPlayers", {id: m_players[id]} )
	
