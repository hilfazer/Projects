extends Node

const UtilityGd              = preload("res://Utility.gd")

const DefaultPort = 10567
const MaxPeers = 12
const ServerId = 1
const ServerDisconnectedError = "Server disconnected"

var m_playerName                       setget setPlayerName
var m_ip                               setget setIp

# Names for players, including host, in id:name format
var m_players = {}                     setget deleted

# dictionary in NodePath : clientId list format
var m_nodesWithClients = {}            setget deleted


signal playerListChanged()
signal playerJoined(id, name)
signal connectionFailed()
signal connectionSucceeded()
signal connectionEnded()
signal networkPeerChanged()
signal networkError(what)
signal gameHosted()
signal serverGameStatus(isLive)
signal nodeRegisteredClientsChanged( nodePath )


func deleted():
	assert(false)


func _ready():
	# this is called at both client and server side
	get_tree().connect("network_peer_disconnected", self,"disconnectClient")

	# called only at client side
	get_tree().connect("connected_to_server", self, "connectToServer")
	get_tree().connect("connection_failed", self, "onConnectionFailure")
	get_tree().connect("server_disconnected", self, "onServerDisconnected")


func disconnectClient(id):
	if not isServer():
		return

	unregisterPlayer(id)
	for p_id in m_players:
		if p_id != get_tree().get_network_unique_id():
			rpc_id(p_id, "unregisterPlayer", id)

	unregisterAllNodesForClient( id )


func connectToServer():
	assert(not isServer() )

	rpc_id(ServerId, "registerPlayer", get_tree().get_network_unique_id(), m_playerName)
	emit_signal("connectionSucceeded")
	rpc_id(ServerId, "sendGameStatus", get_tree().get_network_unique_id())


func onConnectionFailure():
	assert(not isServer() )
	setNetworkPeer(null) # Remove peer
	emit_signal("connectionFailed")


func onServerDisconnected():
	endConnection()
	emit_signal( "networkError", ServerDisconnectedError )


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
	emit_signal("playerListChanged")


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
	m_nodesWithClients.clear()
	emit_signal("playerListChanged")
	emit_signal("connectionEnded")
	setNetworkPeer(null)


func isServer():
	return get_tree().has_network_peer() and get_tree().is_network_server()


master func sendGameStatus( clientId ):
	assert( isServer() )
	var isLive = Connector.isGameInProgress()
	rpc_id( clientId, "receiveGameStatus", isLive )


remote func receiveGameStatus( isLive ):
	assert( not isServer() )
	emit_signal("serverGameStatus", isLive)


func setNetworkPeer(host):
	get_tree().set_network_peer(host)

	var peerId = str(host.get_unique_id()) if get_tree().has_network_peer() else null
	if peerId != null:
		peerId += " (server)" if get_tree().is_network_server() else " (client)"

	Connector.updateVariable( "network_host_ID", peerId )
	emit_signal("networkPeerChanged")


func setPlayerName( playerName ):
	m_playerName = playerName


func setIp( ip ):
	m_ip = ip


func isPlayerNameUnique( playerName ):
	return not playerName in m_players.values()


# returns Ids of players other than yourself
func getOtherPlayersIds():
	var otherPlayersIds = []
	for playerId in m_players:
		if playerId != get_tree().get_network_unique_id():
			otherPlayersIds.append( playerId )
	return otherPlayersIds


# call it when client is ready to receive RPCs for this node and possibly its subnodes
# for some nodes it will be as soon as _ready() callback gets called
# other nodes will need to get some data from server first
master func registerNodeForClient( nodePath ):
	var clientId = get_tree().get_rpc_sender_id()
	if clientId in [0, ServerId]:
		UtilityGd.log("Network: registerNodeForClient() not called for client")
		return

	if m_nodesWithClients.has(nodePath) and clientId in m_nodesWithClients[nodePath]:
		UtilityGd.log("Network: node " + nodePath + " already registered for client " + str(clientId))
		return

	if not m_nodesWithClients.has(nodePath):
		m_nodesWithClients[nodePath] = []
	m_nodesWithClients[nodePath].append( clientId )
	emit_signal( "nodeRegisteredClientsChanged", nodePath )


# call it for nodes for which registerNodeForClient() was called previously
# usually it should be called in node's _exit_tree() callback
master func unregisterNodeForClient( nodePath ):
	var clientId = get_tree().get_rpc_sender_id()
	if clientId in [0, ServerId]:
		return

	if not (m_nodesWithClients.has(nodePath) and clientId in m_nodesWithClients[nodePath]):
		UtilityGd.log("Network: node " + nodePath + " not registered for client " + str(clientId))
		return

	m_nodesWithClients[nodePath].erase( clientId )
	emit_signal( "nodeRegisteredClientsChanged", nodePath )


func unregisterAllNodesForClient( clientId ):
	for nodePath in m_nodesWithClients.keys():
		m_nodesWithClients[nodePath].erase( clientId )
		emit_signal( "nodeRegisteredClientsChanged", nodePath )


# calls rpc for clients who are interested in it
func RPC( node, functionAndArgumentsArray ):
	assert( isServer() )
	for rpcTarget in node.m_rpcTargets:
		node.callv( "rpc_id", [rpcTarget] + functionAndArgumentsArray )


func RPCu( node, functionAndArgumentsArray ):
	assert( isServer() )
	for rpcTarget in node.m_rpcTargets:
		node.callv( "rpc_unreliable_id", [rpcTarget] + functionAndArgumentsArray )


func RSET( node, argumentsArray ):
	assert( isServer() )
	for rpcTarget in node.m_rpcTargets:
		node.callv( "rset_id", [rpcTarget] + argumentsArray )


func RSETu( node, argumentsArray ):
	assert( isServer() )
	for rpcTarget in node.m_rpcTargets:
		node.callv( "rset_unreliable_id", [rpcTarget] + argumentsArray )
	

