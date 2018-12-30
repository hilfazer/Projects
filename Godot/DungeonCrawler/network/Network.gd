extends Node

const RemoteCallerGd         = preload("res://network/RemoteCaller.gd")
const MapWrapperGd           = preload("res://addons/TypeWrappers/MapWrapper.gd")

const DefaultPort = 10567
const MaxPeers = 12
const ServerId = 1
const ServerDisconnectedError = "Server disconnected"

var m_clientName : String              setget deleted
var m_ip : String                      setget deleted

# Names for clients, including host, in id:name format
var m_clients : MapWrapperGd           setget deleted
var m_remoteCaller : RemoteCallerGd    setget deleted


signal clientListChanged( clientList )
signal clientJoined( id, clientName )
signal connectionFailed()
signal connectionSucceeded()
signal connectionEnded()
signal networkPeerChanged()
signal networkError( what )
signal gameHosted()
signal serverGameStatus( isLive )
signal nodeRegisteredClientsChanged( nodePath, nodesWithClients )


func deleted(_a):
	assert(false)


func _enter_tree():
	reset()
	m_clients.connect( "changed", self, "emitClientListChanged" )

	# this is called at both client and server side
	get_tree().connect( "network_peer_disconnected", self,"disconnectClient" )

	# called only at client side
	get_tree().connect( "connected_to_server", self, "connectToServer" )
	get_tree().connect( "connection_failed", self, "onConnectionFailure" )
	get_tree().connect( "server_disconnected", self, "onServerDisconnected" )
	
	
func reset():
	m_clients = MapWrapperGd.new()
	m_clientName = ""
	m_ip = ""
	if m_remoteCaller:
		m_remoteCaller.m_nodesWithClients.clear()
	else:
		setRemoteCaller( RemoteCallerGd.new() )
	
	setNetworkPeer( null )


func disconnectClient( id : int ):
	if not isServer():
		return

	unregisterClient(id)
	for p_id in m_clients.m_dict:
		if p_id != get_tree().get_network_unique_id():
			RPCid( self, p_id, ["unregisterClient", id] )

	unregisterAllNodesForClient( id )


func connectToServer():
	assert( not isServer() )

	RPCid( self, ServerId, ["registerClient", get_tree().get_network_unique_id(), m_clientName] )
	emit_signal( "connectionSucceeded" )
	RPCid( self, ServerId, ["sendGameStatus", get_tree().get_network_unique_id()] )


func onConnectionFailure():
	assert( not isServer() )
	setNetworkPeer( null ) # Remove peer
	emit_signal( "connectionFailed" )


func onServerDisconnected():
	endConnection()
	emit_signal( "networkError", ServerDisconnectedError )


remote func registerClient( id : int, clientName : String ):
	if ( isServer() ):
		if not isClientNameUnique( clientName ):
			RPCid( self, id, ["disconnectFromServer", "Client name already connected"] )
			return

		rpc( "registerClient", id, clientName ) # send new client to all clients
		for clientId in m_clients.m_dict:
			if not id == get_tree().get_network_unique_id():
				# Send other clients to new dude
				RPCid( self, id, ["registerClient", clientId, m_clients.m_dict[clientId]] )

		emit_signal("clientJoined", id)

	m_clients.add( {id : clientName} )


puppet func unregisterClient( id : int ):
	m_clients.remove( [id] )


func hostGame( ip : String, hostName : String ):
	var host = NetworkedMultiplayerENet.new()

	if host.create_server( DefaultPort, MaxPeers ) != 0:
		emit_signal( "networkError", "Could not host game" )
		return FAILED
	else:
		setNetworkPeer( host )
		joinGame( ip, hostName )
		emit_signal( "gameHosted" )
		return OK


func joinGame( ip : String, clientName : String ):
	m_clientName = clientName

	if ( isServer() ):
		registerClient( get_tree().get_network_unique_id(), m_clientName )
	else:
		var host = NetworkedMultiplayerENet.new()
		host.create_client( ip, DefaultPort )
		setNetworkPeer (host )

	m_ip = ip


func endConnection():
	reset()
	emit_signal( "connectionEnded" )


func isServer():
	return get_tree().has_network_peer() and get_tree().is_network_server()


func isClient():
	return get_tree().has_network_peer() and not get_tree().is_network_server()


master func sendGameStatus( clientId : int ):
	assert( isServer() )
	var isLive = Connector.isGameInProgress()
	RPCid( self, clientId, ["receiveGameStatus", isLive] )


remote func receiveGameStatus( isLive ):
	assert( not isServer() )
	emit_signal( "serverGameStatus", isLive )


func setNetworkPeer( host : NetworkedMultiplayerENet ):
	assert( host != null or get_tree().has_network_peer() != null )
	get_tree().set_network_peer( host )

	var peerId = host.get_unique_id() if get_tree().has_network_peer() else 0
	if peerId != 0:
		peerId = str(peerId)
		peerId += " (server)" if get_tree().is_network_server() else " (client)"

	Debug.updateVariable( "network_host_ID", peerId )
	emit_signal("networkPeerChanged")


func setRemoteCaller( caller : RemoteCallerGd ):
	if m_remoteCaller:
		m_remoteCaller.move( caller )

	m_remoteCaller = caller
	m_remoteCaller.connect("nodeRegisteredClientsChanged", self, "nodeRegisteredClientsChanged")


func isClientNameUnique( clientName ):
	return not clientName in m_clients.m_dict.values()


func getOtherClientsIds():
	var otherClientsIds = []
	for clientId in m_clients.m_dict:
		if clientId != get_tree().get_network_unique_id():
			otherClientsIds.append( clientId )
	return otherClientsIds


func emitClientListChanged( clients : Dictionary ):
	emit_signal( "clientListChanged", clients )


func nodeRegisteredClientsChanged( nodePath, nodesWithClients ):
	emit_signal( "nodeRegisteredClientsChanged", nodePath, nodesWithClients )


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
master func unregisterNodeForClient( nodePath : NodePath ):
	var clientId = get_tree().get_rpc_sender_id()
	if clientId in [0, Network.ServerId]:
		return
	else:
		m_remoteCaller.unregisterNodeForClient( nodePath, clientId )


func unregisterAllNodesForClient( clientId : int ):
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
