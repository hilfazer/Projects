extends Node

const PlayerAgentGd          = preload("res://agents/PlayerAgent.gd")
const UtilityGd              = preload("res://Utility.gd")
const GlobalGd               = preload("res://GlobalNames.gd")

const NoOwnerId = 0

enum UnitFields { OWNER, NODE }

var m_playerUnits = []                 setget deleted # _setPlayerUnits
var m_rpcTargets = []                  setget deleted
var m_agents = []                      setget deleted


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
	call_deferred( "_createAgent", get_tree().get_network_unique_id() )


func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		_freeIfNotInScene( m_playerUnits )


func createPlayerUnits( unitsCreationData ):
	var playerUnits = []
	for unitData in unitsCreationData:
		var unitNode_ = load( unitData["path"] ).instance()
		unitNode_.set_name( str( Network.m_clients[unitData["owner"]] ) + "_" )
		unitNode_.setNameLabel( Network.m_clients[unitData["owner"]] )
		playerUnits.append( {UnitFields.OWNER : unitData["owner"], UnitFields.NODE : unitNode_ } )

	_setPlayerUnits( playerUnits )


func getPlayerUnitNodes( unitOwner = null ):
	var nodes = []
	for unit in m_playerUnits:
		if is_instance_valid(unit[UnitFields.NODE]):
			assert( unit[UnitFields.OWNER] in Network.m_clients or unit[UnitFields.OWNER] == NoOwnerId )
			if unitOwner and unitOwner != unit[UnitFields.OWNER]:
				continue

			nodes.append( unit[UnitFields.NODE] )

	return nodes


func resetPlayerUnits( playerUnitsPaths ):
	var playerUnits = []
	for unitPath in playerUnitsPaths:
		var unit = _unitFromNodePath( unitPath )
		if unit:
			playerUnits.append(unit)

	_setPlayerUnits( playerUnits )
	
	
func assignUnitsToAgents():
	for agent in m_agents:
		_assignUnitsToAgent( agent.name )


func onClientListChanged( clientList ):
	if not is_network_master():
		return

	#if a unit's owner is no longer connected unassign its units
	for unit in m_playerUnits:
		if not unit[UnitFields.OWNER] in clientList.keys():
			_unassignUnit( unit[UnitFields.NODE] )
			unit[UnitFields.OWNER] = NoOwnerId

	#remove not connected clients
	for agentNode in get_children():
		if not int(agentNode.name) in clientList.keys():
			 agentNode.queue_free()


func _setPlayerUnits( playerUnits : Array ):
	assert( is_network_master() )
	_freeIfNotInScene( m_playerUnits )
	m_playerUnits = playerUnits

	for unit in m_playerUnits:
		unit[UnitFields.NODE].connect( "tree_exiting", self, "_unassignUnit", [unit[UnitFields.NODE]] )

	for agent in m_agents:
		_assignUnitsToAgent( agent.name )


func _unassignUnit( unitNode : Node ):
	var unitOwner
	for unit in m_playerUnits:
		if unit[UnitFields.NODE] == unitNode:
			unitOwner = unit[UnitFields.OWNER]
			break

	if unitOwner and has_node( str(unitOwner) ):
		get_node( str(unitOwner) ).unassignUnits( [unitNode] )


func _unitFromNodePath( nodePath ):
	var node = get_tree().get_root().get_node( nodePath )
	if !node:
		UtilityGd.log("PlayerManager: no node with path %s" % nodePath )
		return null

	var unit = {}
	unit[UnitFields.NODE] = node
	unit[UnitFields.OWNER] = get_tree().get_network_unique_id()
	node.setNameLabel( Network.m_clients[unit[UnitFields.OWNER]] )
	return unit


master func _createAgent( playerId : int ):
	assert( not has_node( str( playerId ) ) )
	var playerAgent = PlayerAgentGd.new()
	playerAgent.name = str( playerId )
	add_child( playerAgent )
	assert( has_node( str( playerId ) ) )
	playerAgent.set_network_master( playerId )

	if is_network_master():
		playerAgent.connect("unitsAssigned", self, "_onUnitsAssigned")
		playerAgent.connect("unitsUnassigned", self, "_onUnitsUnassigned")
		_assignUnitsToAgent( str( playerId ) )
		m_agents.append( playerAgent )
	else:
		rpc("_createAgent", playerId )
		playerAgent.connect( "tree_exiting", self, "_deleteAgent", [playerId] )


master func _deleteAgent( playerId : int ):
	if get_tree().get_rpc_sender_id() != playerId:
		return

	assert( has_node( str( playerId ) ) )
	get_node( str( playerId ) ).queue_free()
	m_agents.remove( m_agents.find( get_node( str( playerId ) ) ) )


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
			if unitNode == unit[UnitFields.NODE]:
				unitNode.setNameLabel( Network.m_clients[unit[UnitFields.OWNER]] )


func _onUnitsUnassigned( units : Array ):
	for unit in units:
		unit.setNameLabel( "" )


func _freeIfNotInScene( units : Array ):
	for unit in units:
		if is_instance_valid( unit[UnitFields.NODE] ) and \
			not unit[UnitFields.NODE].is_inside_tree():
			unit[UnitFields.NODE].free()


func _unassignAllUnits():
	var agentId2units = {}
	for unit in m_playerUnits:
		if not agentId2units.has( unit[UnitFields.OWNER] ):
			agentId2units[ unit[UnitFields.OWNER] ] = []

		agentId2units[ unit[UnitFields.OWNER] ].append( unit[UnitFields.NODE] )

	for agentId in agentId2units:
		var agentNode = get_node( str(agentId) )
		if agentNode:
			agentNode.unassignUnits( agentId2units[agentId] )


func _registerCommands():
	if not is_network_master():
		return

	var unassignUnits = "unassignUnits"
	Console.register(unassignUnits, {
		'description' : "unassigns all player units",
		'target' : [self, '_unassignAllUnits']
	} )
	connect( "tree_exiting", Console, "deregister", [unassignUnits] )


