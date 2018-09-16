extends Node

const PlayerAgentGd          = preload("res://agents/PlayerAgent.gd")
const UtilityGd              = preload("res://Utility.gd")

const NoOwnerId = 0

enum UnitFields { OWNER, NODE }

var m_playerUnits = []                 setget deleted # _setPlayerUnits
var m_rpcTargets = []                  setget deleted


func deleted(_a):
	assert(false)


signal agentReady( agentNodeName )


func _enter_tree():
	m_rpcTargets = get_parent().m_rpcTargets
	_registerCommands()


func _ready():
	Connector.connectPlayerManager( self )
	onClientListChanged( Network.m_clients )
	connect("agentReady", self, "_assignUnitsToAgent")


func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		_freeIfNotInScene( m_playerUnits )


func createPlayerUnits( unitsCreationData ):
	var playerUnits = []
	for unitData in unitsCreationData:
		var unitNode_ = load( unitData["path"] ).instance()
		unitNode_.set_name( str( Network.m_clients[unitData["owner"]] ) + "_" )
		unitNode_.setNameLabel( Network.m_clients[unitData["owner"]] )
		playerUnits.append( {OWNER : unitData["owner"], NODE : unitNode_ } )

	_setPlayerUnits( playerUnits )


func spawnPlayerAgents():
	assert( is_network_master() )

	var owners = []
	for unit in m_playerUnits:
		if not unit[OWNER] in owners:
			owners.append( unit[OWNER] )

	for unitOwner in owners:
		if not has_node( str(unitOwner) ):
			_createPlayerAgent( unitOwner )
		else:
			if get_node( str(unitOwner) ).is_network_master():
				emit_signal('agentReady', str(unitOwner))
			else:
				rpc_id(unitOwner, "_makeAgentReady")


func getPlayerUnitNodes( unitOwner = null ):
	var nodes = []
	for unit in m_playerUnits:
		if is_instance_valid(unit[NODE]):
			assert( unit[OWNER] in Network.m_clients or unit[OWNER] == NoOwnerId )
			if unitOwner and unitOwner != unit[OWNER]:
				continue

			nodes.append( unit[NODE] )

	return nodes


func resetPlayerUnits( playerUnitsPaths ):
	var playerUnits = []
	for unitPath in playerUnitsPaths:
		var unit = _unitFromNodePath( unitPath )
		if unit:
			playerUnits.append(unit)

	_setPlayerUnits( playerUnits )
	spawnPlayerAgents()


func onClientListChanged( clientList ):
	if not is_network_master():
		return

	#if a unit's owner is no longer connected unassign its units
	for unit in m_playerUnits:
		if not unit[OWNER] in clientList.keys():
			_unassignUnit( unit[NODE] )
			unit[OWNER] = NoOwnerId

	#remove not connected clients
	for agentNode in get_children():
		if not int(agentNode.name) in clientList.keys():
			 agentNode.queue_free()


func _setPlayerUnits( playerUnits : Array ):
	assert( is_network_master() )
	_freeIfNotInScene( m_playerUnits )
	m_playerUnits = playerUnits
	for unit in m_playerUnits:
		unit[NODE].connect("tree_exiting", self, "_unassignUnit", [unit[NODE]])


func _unassignUnit( unitNode ):
	var unitOwner
	for unit in m_playerUnits:
		if unit[NODE] == unitNode:
			unitOwner = unit[OWNER]
			break

	if unitOwner and has_node( str(unitOwner) ):
		get_node( str(unitOwner) ).unassignUnits( [unitNode] )


func _unitFromNodePath( nodePath ):
	var node = get_tree().get_root().get_node( nodePath )
	if !node:
		UtilityGd.log("PlayerManager: no node with path %s" % nodePath )
		return null

	var unit = {}
	unit[NODE] = node
	unit[OWNER] = get_tree().get_network_unique_id()
	node.setNameLabel( Network.m_clients[unit[OWNER]] )
	return unit


slave func _createPlayerAgent( playerId : int ):
	assert( not has_node( str( playerId ) ) )
	var playerAgent = PlayerAgentGd.new()
	playerAgent.name = str( playerId )
	add_child( playerAgent )
	playerAgent.connect("unitsAssigned", self, "_onUnitsAssigned")
	playerAgent.connect("unitsUnassigned", self, "_onUnitsUnassigned")
	assert( has_node( str( playerId ) ) )

	if is_network_master() and playerId != get_network_master():
		rpc_id( playerId, "_createPlayerAgent", playerId )

	elif is_network_master() and playerId == get_network_master():
		emit_signal("agentReady", str(playerId) )

	elif not is_network_master():
		playerAgent.set_network_master(playerId)
		rpc( "_agentCreated", get_tree().get_network_unique_id() )


master func _agentCreated( playerId : int ):
	if playerId != get_tree().get_rpc_sender_id():
		UtilityGd.log("playerId != get_tree().get_rpc_sender_id()")
		return

	get_node( str(playerId) ).set_network_master(playerId)
	emit_signal("agentReady", str(playerId) )


func _assignUnitsToAgent( agentName ):
	assert( is_network_master() )
	assert( get_node( agentName ).m_units.empty() )
	get_node(agentName).assignUnits( getPlayerUnitNodes( int(agentName) ) )


func _onUnitsAssigned( units : Array ):
	for unitNode in units:
		for unit in m_playerUnits:
			if unitNode == unit[NODE]:
				unitNode.setNameLabel( Network.m_clients[unit[OWNER]] )


func _onUnitsUnassigned( units : Array ):
	for unit in units:
		unit.setNameLabel( "" )


func _freeIfNotInScene( units : Array ):
	for unit in units:
		if is_instance_valid( unit[NODE] ) and not unit[NODE].is_inside_tree():
			unit[NODE].free()


func _unassignAllUnits():
	var agentId2units = {}
	for unit in m_playerUnits:
		if not agentId2units.has( unit[OWNER] ):
			agentId2units[ unit[OWNER] ] = []

		agentId2units[ unit[OWNER] ].append( unit[NODE] )

	for agentId in agentId2units:
		var agentNode = get_node( str(agentId) )
		if agentNode:
			agentNode.unassignUnits( agentId2units[agentId] )


slave func _makeAgentReady():
	rpc( "_agentCreated", get_tree().get_network_unique_id() )


func _registerCommands():
	if not is_network_master():
		return

	var unassignUnits = "unassignUnits"
	Console.register(unassignUnits, {
		'description' : "unassigns all player units",
		'target' : [self, '_unassignAllUnits']
	} )
	connect( "tree_exiting", Console, "deregister", [unassignUnits] )


