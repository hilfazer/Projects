extends Node

const DefaultPort = 10567
const MaxPeers = 12
const ServerId = 1

var m_playerName             setget setPlayerName
var m_ip                     setget setIp
# Names for players, including host, in id:name format
var m_players = {}           setget deleted
var m_playersReady = []      setget deleted, deleted


signal playerListChanged()
signal playerJoined(id, name)
signal connectionFailed()
signal connectionSucceeded()
signal networkPeerChanged()
signal networkError(what)
signal allPlayersReady()
signal gameEnded()


func deleted():
	assert(false)


func _ready():
	# this is called at both client and server side
	get_tree().connect("network_peer_connected", self, "connectClient")
	get_tree().connect("network_peer_disconnected", self,"disconnectClient")

	# called only at client side
	get_tree().connect("connected_to_server", self, "connectToServer")
	get_tree().connect("connection_failed", self, "onConnectionFailure")
	get_tree().connect("server_disconnected", self, "disconnectFromServer")


func connectClient(id):
	pass


func disconnectClient(id):
	if not isServer():
		return

	unregisterPlayer(id)
	for p_id in m_players:
		if p_id != get_tree().get_network_unique_id():
			rpc_id(p_id, "unregisterPlayer", id)


func connectToServer():
	assert(not get_tree().is_network_server())

	rpc_id(ServerId, "registerPlayer", get_tree().get_network_unique_id(), m_playerName)
	emit_signal("connectionSucceeded")


func disconnectFromServer():
	assert(not get_tree().is_network_server())
	emit_signal("networkError", "Server disconnected")
	endGame()


func onConnectionFailure():
	assert(not get_tree().is_network_server())
	setNetworkPeer(null) # Remove peer
	emit_signal("connectionFailed")


remote func registerPlayer(id, name):
	if (get_tree().is_network_server()):
		rpc("registerPlayer", id, name) # send new player to all clients
		for playerId in m_players:
			if not id == get_tree().get_network_unique_id():
				rpc_id(id, "registerPlayer", playerId, m_players[playerId]) # Send other players to new dude

		emit_signal("playerJoined", id)

	m_players[id] = name
	emit_signal("playerListChanged")


slave func unregisterPlayer(id):
	m_players.erase(id)
	m_playersReady.erase(id)
	emit_signal("playerListChanged")


remote func readyToStart(id):
	assert(get_tree().is_network_server())
	assert(not id in m_playersReady)

	if (id in m_players):
		m_playersReady.append(id)

	if (m_playersReady.size() < m_players.size()):
		return

	emit_signal("allPlayersReady")


func hostGame(name):
	setPlayerName(name)
	var host = NetworkedMultiplayerENet.new()
	
	if host.create_server(DefaultPort, MaxPeers) != 0:
		emit_signal("networkError", "Could not host game")
		return
	else:
		setNetworkPeer(host)


func joinGame(ip, name):
	setPlayerName(name)

	# server can join as one of the players
	if (isServer()):
		registerPlayer(get_tree().get_network_unique_id(), m_playerName)
	else:
		var host = NetworkedMultiplayerENet.new()
		host.create_client(ip, DefaultPort)
		setNetworkPeer(host)

	setIp(ip)


func endGame():
	emit_signal("gameEnded")
	m_players.clear()
	m_playersReady.clear()
	emit_signal("playerListChanged")
	setNetworkPeer(null)


func isServer():
	return get_tree().has_network_peer() and get_tree().is_network_server()


func setNetworkPeer(host):
	get_tree().set_network_peer(host)

	var peerId = str(host.get_instance_ID()) if get_tree().has_network_peer() else null
	if peerId != null:
		peerId += " (server)" if get_tree().is_network_server() else " (client)"

	Utilities.emit_signal("sendVariable", "network_host_ID", peerId )
	emit_signal("networkPeerChanged")


func setPlayerName( name ):
	m_playerName = name


func setIp( ip ):
	m_ip = ip


# called by player who want to join live game after registering himself/herself
remote func addRegisteredPlayerToGame(id):
	if id in m_players:
		get_node("LevelLoader").rpc( "insertPlayers", {id: m_players[id]} )

