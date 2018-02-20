extends Node

const DefaultPort = 10567
const MaxPeers = 12
const ServerId = 1

var m_playerName             setget setPlayerName
var m_ip                     setget setIp
# Names for players, including host, in id:name format
var m_players = {}           setget deleted
var m_playersReady = []      setget deleted


signal playerListChanged()
signal playerJoined(id, name)
signal connectionFailed()
signal connectionSucceeded()
signal connectionEnded()
signal networkPeerChanged()
signal networkError(what)
signal allPlayersReady()
signal gameHosted()
signal serverGameStatus(isLive)


func deleted():
	assert(false)


func _ready():
	# this is called at both client and server side
	get_tree().connect("network_peer_disconnected", self,"disconnectClient")

	# called only at client side
	get_tree().connect("connected_to_server", self, "connectToServer")
	get_tree().connect("connection_failed", self, "onConnectionFailure")
	get_tree().connect("server_disconnected", self, "disconnectFromServer")


func disconnectClient(id):
	if not isServer():
		return

	unregisterPlayer(id)
	for p_id in m_players:
		if p_id != get_tree().get_network_unique_id():
			rpc_id(p_id, "unregisterPlayer", id)


func connectToServer():
	assert(not isServer() )

	rpc_id(ServerId, "registerPlayer", get_tree().get_network_unique_id(), m_playerName)
	emit_signal("connectionSucceeded")
	rpc_id(ServerId, "askGameStatus", get_tree().get_network_unique_id())


remote func disconnectFromServer( reason = "Server disconnected" ):
	assert( not isServer() )
	emit_signal("networkError", reason)
	endConnection()


func onConnectionFailure():
	assert(not isServer() )
	setNetworkPeer(null) # Remove peer
	emit_signal("connectionFailed")


remote func registerPlayer(id, playerName):
	if ( isServer() ):
		if not isPlayerNameUnique( playerName ):
			rpc_id(id, "disconnectFromServer", "Player name already connected")
			return

		rpc("registerPlayer", id, playerName) # send new player to all clients
		for playerId in m_players:
			if not id == get_tree().get_network_unique_id():
				rpc_id(id, "registerPlayer", playerId, m_players[playerId]) # Send other players to new dude

		emit_signal("playerJoined", id)

	m_players[id] = playerName
	emit_signal("playerListChanged")


slave func unregisterPlayer(id):
	m_players.erase(id)
	m_playersReady.erase(id)
	emit_signal("playerListChanged")


remote func readyToStart(id):
	assert( isServer() )
	assert(not id in m_playersReady)

	if (id in m_players):
		m_playersReady.append(id)

	if (m_playersReady.size() < m_players.size()):
		return

	emit_signal("allPlayersReady")


func hostGame(ip, hostName):
	var host = NetworkedMultiplayerENet.new()

	if host.create_server(DefaultPort, MaxPeers) != 0:
		emit_signal("networkError", "Could not host game")
		return FAILED
	else:
		setNetworkPeer(host)
		joinGame(ip, hostName)
		emit_signal("gameHosted")
		return OK


func joinGame(ip, clientName):
	setPlayerName(clientName)

	if (isServer()):
		registerPlayer(get_tree().get_network_unique_id(), m_playerName)
	else:
		var host = NetworkedMultiplayerENet.new()
		host.create_client(ip, DefaultPort)
		setNetworkPeer(host)

	setIp(ip)


func endConnection():
	m_players.clear()
	m_playersReady.clear()
	emit_signal("playerListChanged")
	emit_signal("connectionEnded")
	setNetworkPeer(null)


func isServer():
	return get_tree().has_network_peer() and get_tree().is_network_server()


remote func askGameStatus( clientId ):
	assert( isServer() )
	var isLive = Connector.isGameInProgress()
	rpc_id( clientId, "getGameStatus", isLive )


remote func getGameStatus( isLive ):
	assert( isServer() == false )
	emit_signal("serverGameStatus", isLive)


func setNetworkPeer(host):
	get_tree().set_network_peer(host)

	var peerId = str(host.get_unique_id()) if get_tree().has_network_peer() else null
	if peerId != null:
		peerId += " (server)" if get_tree().is_network_server() else " (client)"

	Connector.emit_signal("sendVariable", "network_host_ID", peerId )
	emit_signal("networkPeerChanged")


func setPlayerName( playerName ):
	m_playerName = playerName


func setIp( ip ):
	m_ip = ip


func isPlayerNameUnique( playerName ):
	return not playerName in m_players.values()


func getOtherPlayersIds():
	var otherPlayersIds = []
	for playerId in m_players:
		if playerId != get_tree().get_network_unique_id():
			otherPlayersIds.append( playerId )
	return otherPlayersIds

