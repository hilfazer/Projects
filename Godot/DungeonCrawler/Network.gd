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
signal allPlayersReady()
signal gameEnded()
signal gameError(what)


func deleted():
	assert(false)


func _ready():
	get_tree().connect("network_peer_connected", self, "clientConnected")
	get_tree().connect("network_peer_disconnected", self,"clientDisconnected")
	get_tree().connect("connected_to_server", self, "connectedToServer")
	get_tree().connect("connection_failed", self, "connectedFail")
	get_tree().connect("server_disconnected", self, "serverDisconnected")


# this is called at both client and server side
func clientConnected(id):
	pass


# this is called at both client and server side
func clientDisconnected(id):
	if not isServer():
		return

	unregisterPlayer(id)
	for p_id in m_players:
		if p_id != get_tree().get_network_unique_id():
			rpc_id(p_id, "unregisterPlayer", id)


# called only at client side
func connectedToServer():
	assert(not get_tree().is_network_server())

	rpc_id(ServerId, "registerPlayer", get_tree().get_network_unique_id(), m_playerName)
	emit_signal("connectionSucceeded")


# called only at client side
func serverDisconnected():
	assert(not get_tree().is_network_server())
	emit_signal("gameError", "Server disconnected")
	endGame()


# called only at client side
func connectedFail():
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
		emit_signal("gameError", "Could not host game")
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

