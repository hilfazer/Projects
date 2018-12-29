extends Node

const RemoteCallerGd         = preload("res://network/RemoteCaller.gd")

const DefaultPort = 10567
const MaxPeers = 12
const ServerId = 1
const ServerDisconnectedError = "Server disconnected"

var m_clientName                       setget setClientName
var m_ip                               setget setIp

# Names for clients, including host, in id:name format
var m_clients = {}                     setget deleted
var m_remoteCaller : RemoteCallerGd


signal clientListChanged(clientList)
signal clientJoined(id, name)
signal connectionFailed()
signal connectionSucceeded()
signal connectionEnded()
signal networkPeerChanged()
signal networkError(what)
signal gameHosted()
signal serverGameStatus(isLive)
signal nodeRegisteredClientsChanged(nodePath, nodesWithClients)


func deleted(_a):
	assert(false)


func _ready():
	setRemoteCaller( RemoteCallerGd.new( get_tree() ) )

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
			RPCid( self, p_id, ["unregisterClient", id] )

	unregisterAllNodesForClient( id )


func connectToServer():
	assert(not isServer() )

	RPCid( self, ServerId, ["registerClient", get_tree().get_network_unique_id(), m_clientName] )
	emit_signal("connectionSucceeded")
	RPCid( self, ServerId, ["sendGameStatus", get_tree().get_network_unique_id()] )


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
			RPCid( self, id, ["disconnectFromServer", "Client name already connected"] )
			return

		rpc("registerClient", id, clientName) # send new client to all clients
		for clientId in m_clients:
			if not id == get_tree().get_network_unique_id():
				# Send other clients to new dude
				RPCid( self, id, ["registerClient", clientId, m_clients[clientId]] )

		emit_signal("clientJoined", id)

	m_clients[id] = clientName
	emit_signal("clientListChanged", m_clients)


puppet func unregisterClient(id):
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
	m_remoteCaller.m_nodesWithClients.clear()
	emit_signal("clientListChanged", m_clients)
	setNetworkPeer(null)
	emit_signal("connectionEnded")


func isServer():
	return get_tree().has_network_peer() and get_tree().is_network_server()


func isClient():
	return get_tree().has_network_peer() and not get_tree().is_network_server()


master func sendGameStatus( clientId ):
	assert( isServer() )
	var isLive = Connector.isGameInProgress()
	RPCid( self, clientId, ["receiveGameStatus", isLive] )


remote func receiveGameStatus( isLive ):
	assert( not isServer() )
	emit_signal("serverGameStatus", isLive)


func setNetworkPeer(host):
	assert( host != null or get_tree().has_network_peer() != null )
	get_tree().set_network_peer(host)

	var peerId = host.get_unique_id() if get_tree().has_network_peer() else 0
	if peerId != 0:
		peerId = str(peerId)
		peerId += " (server)" if get_tree().is_network_server() else " (client)"

	Debug.updateVariable( "network_host_ID", peerId )
	emit_signal("networkPeerChanged")


func setClientName( clientName ):
	m_clientName = clientName


func setIp( ip ):
	m_ip = ip


func setRemoteCaller( caller : RemoteCallerGd ):
	if m_remoteCaller:
		m_remoteCaller.move( caller )

	m_remoteCaller = caller
	m_remoteCaller.connect("nodeRegisteredClientsChanged", self, "nodeRegisteredClientsChanged")


func isClientNameUnique( clientName ):
	return not clientName in m_clients.values()


func getOtherClientsIds():
	var otherClientsIds = []
	for clientId in m_clients:
		if clientId != get_tree().get_network_unique_id():
			otherClientsIds.append( clientId )
	return otherClientsIds


func nodeRegisteredClientsChanged(nodePath, nodesWithClients):
	emit_signal("nodeRegisteredClientsChanged", nodePath, nodesWithClients)


# call it when client is ready to receive RPCs for this node and possibly its subnodes
# for some nodes it will be as soon as _ready() callback gets called
# other nodes will need to get some data from server first
master func registerNodeForClient( nodePath ):
	var clientId = get_tree().get_rpc_sender_id()
	if clientId in [0, Network.ServerId]:
		Debug.warn( self, "Network: registerNodeForClient() not called for client")
		return
	else:
		m_remoteCaller.registerNodeForClient( nodePath, clientId )


# call it for nodes for which registerNodeForClient() was called previously
# usually it should be called in node's _exit_tree() callback
master func unregisterNodeForClient( nodePath ):
	var clientId = get_tree().get_rpc_sender_id()
	if clientId in [0, Network.ServerId]:
		return
	else:
		m_remoteCaller.unregisterNodeForClient( nodePath, clientId )


func unregisterAllNodesForClient( clientId ):
	m_remoteCaller.unregisterAllNodesForClient( clientId )
	
	
func setRpcTargets( node : Node, targetIds : Array ):
	m_remoteCaller.setRpcTargets( node, targetIds )


# calls rpc for clients who are interested in it
func RPC( node : Node, functionAndArguments : Array ):
	assert( isServer() )
	m_remoteCaller.RPC( node, functionAndArguments )


func RPCu( node : Node, functionAndArguments : Array ):
	assert( isServer() )
	m_remoteCaller.RPCu( node, functionAndArguments )


func RPCid( node : Node, id : int, functionAndArguments : Array ):
	m_remoteCaller.RPCid( node, id, functionAndArguments )


func RPCmaster( node : Node, functionAndArguments : Array ):
	m_remoteCaller.RPCmaster( node, functionAndArguments )


func RPCuid( node : Node, id : int, functionAndArguments : Array ):
	m_remoteCaller.RPCuid( node, id, functionAndArguments )


func RSET( node : Node, arguments : Array ):
	assert( isServer() )
	m_remoteCaller.RSET( node, arguments )


func RSETu( node : Node, arguments : Array ):
	assert( isServer() )
	m_remoteCaller.RSETu( node, arguments )
