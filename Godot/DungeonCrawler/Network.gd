extends Node

const UtilityGd              = preload("res://Utility.gd")

const DefaultPort = 10567
const MaxPeers = 12
const ServerId = 1
const ServerDisconnectedError = "Server disconnected"

var m_clientName                       setget setClientName
var m_ip                               setget setIp

# Names for clients, including host, in id:name format
var m_clients = {}                     setget deleted

# dictionary in NodePath : clientId list format
var m_nodesWithClients = {}            setget deleted


signal clientListChanged(clientList)
signal clientJoined(id, name)
signal connectionFailed()
signal connectionSucceeded()
signal connectionEnded()
signal networkPeerChanged()
signal networkError(what)
signal gameHosted()
signal serverGameStatus(isLive)
signal nodeRegisteredClientsChanged(nodePath)


func deleted(a):
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

	unregisterClient(id)
	for p_id in m_clients:
		if p_id != get_tree().get_network_unique_id():
			rpc_id(p_id, "unregisterClient", id)

	unregisterAllNodesForClient( id )


func connectToServer():
	assert(not isServer() )

	rpc_id(ServerId, "registerClient", get_tree().get_network_unique_id(), m_clientName)
	emit_signal("connectionSucceeded")
	rpc_id(ServerId, "sendGameStatus", get_tree().get_network_unique_id())


func onConnectionFailure():
	assert(not isServer() )
	setNetworkPeer(null) # Remove peer
	emit_signal("connectionFailed")


func onServerDisconnected():
	endConnection()
	emit_signal( "networkError", ServerDisconnectedError )


remote func registerClient(id, clientName):
	if ( isServer() ):
		if not isClientNameUnique( clientName ):
			rpc_id(id, "disconnectFromServer", "Client name already connected")
			return

		rpc("registerClient", id, clientName) # send new client to all clients
		for clientId in m_clients:
			if not id == get_tree().get_network_unique_id():
				rpc_id(id, "registerClient", clientId, m_clients[clientId]) # Send other clients to new dude

		emit_signal("clientJoined", id)

	m_clients[id] = clientName
	emit_signal("clientListChanged", m_clients)


slave func unregisterClient(id):
	m_clients.erase(id)
	emit_signal("clientListChanged", m_clients)


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
	setClientName(clientName)

	if (isServer()):
		registerClient(get_tree().get_network_unique_id(), m_clientName)
	else:
		var host = NetworkedMultiplayerENet.new()
		host.create_client(ip, DefaultPort)
		setNetworkPeer(host)

	setIp(ip)


func endConnection():
	m_clients.clear()
	m_nodesWithClients.clear()
	emit_signal("clientListChanged", m_clients)
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


func setClientName( clientName ):
	m_clientName = clientName


func setIp( ip ):
	m_ip = ip


func isClientNameUnique( clientName ):
	return not clientName in m_clients.values()


# returns Ids of clients other than yourself
func getOtherClientsIds():
	var otherClientsIds = []
	for clientId in m_clients:
		if clientId != get_tree().get_network_unique_id():
			otherClientsIds.append( clientId )
	return otherClientsIds


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
	

