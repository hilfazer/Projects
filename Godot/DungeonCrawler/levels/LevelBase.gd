extends Node2D

const UtilityGd              = preload("res://Utility.gd")


var m_rpcTargets = []                  setget deleted # setRpcTargets


func deleted(_a):
	assert(false)


signal predelete()


func _init():
	Connector.updateVariable("Level count", +1, true)


func _enter_tree():
	if Network.isServer():
		Network.connect("nodeRegisteredClientsChanged", self, "onNodeRegisteredClientsChanged")
	else:
		Network.rpc( "registerNodeForClient", get_path() )


func _exit_tree():
	if Network.isClient():
		Network.rpc( "unregisterNodeForClient", get_path() )
	if is_network_master():
		Network.RPC(self, ["destroy"])


func _ready():
	assert( $"Entrances".get_child_count() > 0 )


func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		emit_signal( "predelete" )
		if is_instance_valid( Connector ):
			Connector.updateVariable("Level count", -1, true)


puppet func destroy():
	if get_tree().get_rpc_sender_id() == Network.ServerId:
		queue_free()


func setGroundTile(tileName, x, y):
	get_node("Ground").setTile(tileName, x, y)


func sendToClient(clientId):
	get_node("Ground").sendToClient(clientId)
	get_node("Units").sendToClient(clientId)


func removeChildUnit( unitNode ):
	assert( get_node("Units").has_node( unitNode.get_path() ) )
	get_node("Units").remove_child( unitNode )


func onNodeRegisteredClientsChanged( nodePath, nodesWithClients ):
	if nodePath == get_path():
		setRpcTargets( nodesWithClients[nodePath] )


func setRpcTargets( clientIds ):
	assert( Network.isServer() )
	m_rpcTargets = clientIds

	for unit in $"Units".get_children():
		unit.setRpcTargets( clientIds )


func findEntranceWithAllUnits( unitNodes ):
	var entranceWithUnits = findEntranceWithAnyUnit( unitNodes )

	if entranceWithUnits:
		if UtilityGd.isSuperset( entranceWithUnits.get_overlapping_bodies(), unitNodes ):
			return entranceWithUnits
	else:
		return null


func findEntranceWithAnyUnit( unitNodes ):
	var entrances = get_node("Entrances").get_children()
	
	var entranceWithAnyUnits
	for entrance in entrances:
		if entranceWithAnyUnits != null:
			break

		for body in entrance.get_overlapping_bodies():
			if unitNodes.has( body ):
				entranceWithAnyUnits = entrance
				break

	return entranceWithAnyUnits
