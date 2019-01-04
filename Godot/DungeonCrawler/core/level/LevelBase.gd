extends Node2D

const UtilityGd              = preload("res://core/Utility.gd")


var m_rpcTargets = []                  # setRpcTargets
onready var m_ground = $"Ground"       setget deleted
onready var m_units = $"Units"         setget deleted
onready var m_entrances = $"Entrances" setget deleted


func deleted(_a):
	assert(false)


signal predelete()


func _init():
	Debug.updateVariable("Level count", +1, true)


func _enter_tree():
	if Network.isServer():
		Network.connect("nodeRegisteredClientsChanged", self, "onNodeRegisteredClientsChanged")
	else:
		Network.rpc( "registerNodeForClient", get_path() )


func _exit_tree():
	if Network.isClient():
		Network.rpc( "unregisterNodeForClient", get_path() )
	elif Network.isServer():
		Network.RPC(self, ["destroy"])


func _ready():
	assert( m_entrances.get_child_count() > 0 )


func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		emit_signal( "predelete" )
		Debug.updateVariable("Level count", -1, true)


puppet func destroy():
	if get_tree().get_rpc_sender_id() == Network.ServerId:
		queue_free()


func setGroundTile(tileName, x, y):
	m_ground.setTile(tileName, x, y)


func sendToClient(clientId):
	m_ground.sendToClient(clientId)
	m_units.sendToClient(clientId)


func removeChildUnit( unitNode ):
	assert( m_units.has_node( unitNode.get_path() ) )
	m_units.remove_child( unitNode )


func onNodeRegisteredClientsChanged( nodePath, nodesWithClients ):
	if nodePath == get_path():
		setRpcTargets( nodesWithClients[nodePath] )


func setRpcTargets( clientIds ):
	assert( Network.isServer() )
	Network.setRpcTargets( self, clientIds )

	for unit in m_units.get_children():
		unit.setRpcTargets( clientIds )


func findEntranceWithAllUnits( unitNodes ):
	var entranceWithUnits = findEntranceWithAnyUnit( unitNodes )

	if entranceWithUnits:
		if UtilityGd.isSuperset( entranceWithUnits.get_overlapping_bodies(), unitNodes ):
			return entranceWithUnits
	else:
		return null


func findEntranceWithAnyUnit( unitNodes ):
	var entrances = m_entrances.get_children()

	var entranceWithAnyUnits
	for entrance in entrances:
		if entranceWithAnyUnits != null:
			break

		for body in entrance.get_overlapping_bodies():
			if unitNodes.has( body ):
				entranceWithAnyUnits = entrance
				break

	return entranceWithAnyUnits
