extends Reference

# dictionary in NodePath : clientId list format
var m_nodesWithClients : Dictionary = {}         setget deleted # _setNodesWithClients
var m_tree                             setget deleted


signal nodeRegisteredClientsChanged(nodePath, nodesWithClients)


func deleted(_a):
	assert(false)


func _init( sceneTree ):
	m_tree = sceneTree


func move( caller ):
	caller._setNodesWithClients( m_nodesWithClients )
	m_nodesWithClients = {}
	
	
func _setNodesWithClients( nodesWithClients : Dictionary ):
	m_nodesWithClients = nodesWithClients


func registerNodeForClient( nodePath, clientId ):
	if m_nodesWithClients.has(nodePath) and clientId in m_nodesWithClients[nodePath]:
		Debug.warn( self, "Network: node %s already registered for client %d" % [nodePath, clientId])
		return

	if not m_nodesWithClients.has(nodePath):
		m_nodesWithClients[nodePath] = []
	m_nodesWithClients[nodePath].append( clientId )
	emit_signal( "nodeRegisteredClientsChanged", nodePath, m_nodesWithClients )


func unregisterNodeForClient( nodePath, clientId ):
	if not (m_nodesWithClients.has(nodePath) and clientId in m_nodesWithClients[nodePath]):
		Debug.warn( self, "Network: node %s  not registered for client %d" % [nodePath, clientId])
		return

	m_nodesWithClients[nodePath].erase( clientId )
	emit_signal( "nodeRegisteredClientsChanged", nodePath, m_nodesWithClients )


func unregisterAllNodesForClient( clientId ):
	for nodePath in m_nodesWithClients.keys():
		m_nodesWithClients[nodePath].erase( clientId )
		emit_signal( "nodeRegisteredClientsChanged", nodePath, m_nodesWithClients )


func setRpcTargets( node : Node, targetIds : Array ):
	node.m_rpcTargets = targetIds


func RPC( node : Node, functionAndArguments : Array ):
	for rpcTarget in node.m_rpcTargets:
		node.callv( "rpc_id", [rpcTarget] + functionAndArguments )


func RPCu( node : Node, functionAndArguments : Array ):
	for rpcTarget in node.m_rpcTargets:
		node.callv( "rpc_unreliable_id", [rpcTarget] + functionAndArguments )


func RPCid( node : Node, id : int, functionAndArguments : Array ):
	node.callv( "rpc_id", [id] + functionAndArguments )


func RPCmaster( node : Node, functionAndArguments : Array ):
	assert( not node.is_network_master() )
	node.callv( "rpc_id", [node.get_network_master()] + functionAndArguments )


func RPCuid( node : Node, id : int, functionAndArguments : Array ):
	node.callv( "rpc_unreliable_id", [id] + functionAndArguments )


func RSET( node : Node, arguments : Array ):
	for rpcTarget in node.m_rpcTargets:
		node.callv( "rset_id", [rpcTarget] + arguments )


func RSETu( node : Node, arguments : Array ):
	for rpcTarget in node.m_rpcTargets:
		node.callv( "rset_unreliable_id", [rpcTarget] + arguments )
