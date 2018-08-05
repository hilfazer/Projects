extends Node

const PlayerUnitGd           = preload("./PlayerUnit.gd")
const PlayerAgentGd          = preload("res://agents/PlayerAgent.gd")
const UtilityGd              = preload("res://Utility.gd")

enum UnitFields { OWNER = PlayerUnitGd.OWNER, WEAKREF_ = PlayerUnitGd.WEAKREF_ }

var m_playerUnits = []                 setget deleted # setPlayerUnits


func deleted(a):
	assert(false)

#TODO create agents for clients with units
func _ready():
	Connector.connectPlayerManager( self )
	onClientListChanged( Network.m_clients )


func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		freeIfNotInScene( m_playerUnits )


func createPlayerUnits( unitsCreationData ):
	var playerUnits = []
	for unitData in unitsCreationData:
		var unitNode_ = load( unitData["path"] ).instance()
		unitNode_.set_name( str( Network.m_clients[unitData["owner"]] ) + "_" )
		unitNode_.setNameLabel( Network.m_clients[unitData["owner"]] )
		playerUnits.append( \
			{OWNER : unitData["owner"], WEAKREF_ : weakref(unitNode_) } )

	setPlayerUnits( playerUnits )


func setPlayerUnits( playerUnits ):
	freeIfNotInScene( m_playerUnits )
	m_playerUnits = playerUnits


func resetPlayerUnits( playerUnitsPaths ):
	var playerUnits = []
	for unitPath in playerUnitsPaths:
		var unit = unitFromNodePath( unitPath )
		if unit:
			playerUnits.append(unit)

	setPlayerUnits( playerUnits )
	assignAgentsToPlayerUnits()


func unitFromNodePath( nodePath ):
	var node = get_tree().get_root().get_node( nodePath )
	if !node:
		UtilityGd.log("PlayerManager: no node with path " + nodePath )
		return null

	var unit = {}
	unit[WEAKREF_] = weakref( node )
	unit[OWNER] = get_tree().get_network_unique_id()
	node.setNameLabel( Network.m_clients[unit[OWNER]] )
	return unit


func onClientListChanged( clientList ):
	if not is_network_master():
		return

	for unit in m_playerUnits:
		if not unit[OWNER] in clientList:
			assignOwnAgent( unit[WEAKREF_].get_ref().get_path() )
			unit[OWNER] = get_tree().get_network_unique_id()


func assignAgentsToPlayerUnits():
	assert( is_network_master() )

	for unit in m_playerUnits:
		var node = unit[WEAKREF_].get_ref()
		if unit[OWNER] == get_tree().get_network_unique_id():
			assignOwnAgent( node.get_path() )
		else:
			rpc_id( unit[OWNER], "assignOwnAgent", node.get_path() )


slave func assignOwnAgent( unitNodePath ):
	var unitNode = get_node( unitNodePath )
	assert( unitNode )
	
	var playerAgent
	if has_node( str(get_tree().get_network_unique_id()) ):
		playerAgent = get_node( str(get_tree().get_network_unique_id()) )
	else:
		playerAgent = PlayerAgentGd.new()
		playerAgent.name = str(get_tree().get_network_unique_id())
		playerAgent.set_network_master( get_tree().get_network_unique_id() )
		add_child(playerAgent)

	playerAgent.assignUnit( unitNode )


func getPlayerUnitNodes():
	var nodes = []
	for unit in m_playerUnits:
		if unit[WEAKREF_] != null:
			assert( unit[OWNER] in Network.m_clients )
			nodes.append( unit[WEAKREF_].get_ref() )

	return nodes


func freeIfNotInScene( units ):
		for unit in units:
			var nodeRef = unit[WEAKREF_].get_ref()
			if nodeRef != null and nodeRef.is_inside_tree():
				nodeRef.free()
