extends Reference

const UtilityGd              = preload("res://Utility.gd")

# dictionary in NodePath : clientId list format
var m_nodesWithClients = {}            setget deleted
var m_tree                             setget deleted


signal nodeRegisteredClientsChanged(nodePath, m_nodesWithClients)


func deleted(_a):
	assert(false)


func _init( sceneTree ):
	m_tree = sceneTree


func registerNodeForClient( nodePath ):
	var clientId = m_tree.get_rpc_sender_id()
	if clientId in [0, Network.ServerId]:
		UtilityGd.log("Network: registerNodeForClient() not called for client")
		return

	if m_nodesWithClients.has(nodePath) and clientId in m_nodesWithClients[nodePath]:
		UtilityGd.log("Network: node %s already registered for client %d" % [nodePath, clientId])
		return

	if not m_nodesWithClients.has(nodePath):
		m_nodesWithClients[nodePath] = []
	m_nodesWithClients[nodePath].append( clientId )
	emit_signal( "nodeRegisteredClientsChanged", nodePath, m_nodesWithClients )


func unregisterNodeForClient( nodePath ):
	var clientId = m_tree.get_rpc_sender_id()
	if clientId in [0, Network.ServerId]:
		return

	if not (m_nodesWithClients.has(nodePath) and clientId in m_nodesWithClients[nodePath]):
		UtilityGd.log("Network: node %s  not registered for client %d" % [nodePath, clientId])
		return

	m_nodesWithClients[nodePath].erase( clientId )
	emit_signal( "nodeRegisteredClientsChanged", nodePath, m_nodesWithClients )


func unregisterAllNodesForClient( clientId ):
	for nodePath in m_nodesWithClients.keys():
		m_nodesWithClients[nodePath].erase( clientId )
		emit_signal( "nodeRegisteredClientsChanged", nodePath, m_nodesWithClients )


func RPC( node : Node, functionAndArguments : Array ):
	for rpcTarget in node.m_rpcTargets:
		node.callv( "rpc_id", [rpcTarget] + functionAndArguments )


func RPCu( node : Node, functionAndArguments : Array ):
	for rpcTarget in node.m_rpcTargets:
		node.callv( "rpc_unreliable_id", [rpcTarget] + functionAndArguments )


func RSET( node : Node, arguments : Array ):
	for rpcTarget in node.m_rpcTargets:
		node.callv( "rset_id", [rpcTarget] + arguments )


func RSETu( node : Node, arguments : Array ):
	for rpcTarget in node.m_rpcTargets:
		node.callv( "rset_unreliable_id", [rpcTarget] + arguments )
