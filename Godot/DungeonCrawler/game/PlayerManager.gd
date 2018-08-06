extends Node

const PlayerUnitGd           = preload("./PlayerUnit.gd")
const PlayerAgentGd          = preload("res://agents/PlayerAgent.gd")
const UtilityGd              = preload("res://Utility.gd")

enum UnitFields { OWNER = PlayerUnitGd.OWNER, WEAKREF_ = PlayerUnitGd.WEAKREF_ }

var m_playerUnits = []                 setget deleted # _setPlayerUnits
var m_rpcTargets = []                  setget deleted

func deleted(a):
	assert(false)


signal agentReady( agentNodeName )


func _enter_tree():
	m_rpcTargets = get_parent().m_rpcTargets
	_registerCommands()


func _exit_tree():
	_unregisterCommands()


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
		playerUnits.append( \
			{OWNER : unitData["owner"], WEAKREF_ : weakref(unitNode_) } )

	_setPlayerUnits( playerUnits )


func spawnPlayerAgents():
	assert( is_network_master() )

	for unit in m_playerUnits:
		var unitNode = unit[WEAKREF_].get_ref()
		if not has_node( str(unit[OWNER]) ):
			_createPlayerAgent( unit[OWNER] )


func getPlayerUnitNodes( unitOwner = null ):
	var nodes = []
	for unit in m_playerUnits:
		if unit[WEAKREF_] != null:
			assert( unit[OWNER] in Network.m_clients )
			if unitOwner and unitOwner != unit[OWNER]:
				continue
			
			nodes.append( unit[WEAKREF_].get_ref() )

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
	#TODO


func _setPlayerUnits( playerUnits ):
	assert( is_network_master() )
	_freeIfNotInScene( m_playerUnits )
	m_playerUnits = playerUnits


func _unitFromNodePath( nodePath ):
	var node = get_tree().get_root().get_node( nodePath )
	if !node:
		UtilityGd.log("PlayerManager: no node with path " + nodePath )
		return null

	var unit = {}
	unit[WEAKREF_] = weakref( node )
	unit[OWNER] = get_tree().get_network_unique_id()
	node.setNameLabel( Network.m_clients[unit[OWNER]] )
	return unit


slave func _createPlayerAgent( playerId ):
	assert( not has_node( str(playerId) ) )
	var playerAgent = PlayerAgentGd.new()
	playerAgent.name = str(playerId)
	add_child(playerAgent)
	assert( has_node( str(playerId) ) )

	if is_network_master() and playerId != get_network_master():
		rpc_id( playerId, "_createPlayerAgent", playerId )
	elif is_network_master() and playerId == get_network_master():
		emit_signal("agentReady", str(playerId) )
	elif not is_network_master():
		playerAgent.set_network_master(playerId)
		rpc( "_agentCreated", get_tree().get_network_unique_id() )


master func _agentCreated( playerId ):
	if playerId != get_tree().get_rpc_sender_id():
		UtilityGd.log("playerId != get_tree().get_rpc_sender_id()")
		return

	get_node( str(playerId) ).set_network_master(playerId)
	emit_signal("agentReady", str(playerId) )
	
	
func _assignUnitsToAgent( agentName ):
	assert( is_network_master() )
	assert( get_node( agentName ).m_units.empty() )
	get_node(agentName).assignUnits( getPlayerUnitNodes( int(agentName) ) )


func _freeIfNotInScene( units ):
		for unit in units:
			var nodeRef = unit[WEAKREF_].get_ref()
			if nodeRef != null and not nodeRef.is_inside_tree():
				nodeRef.free()


func _unassignAllUnits():
	var agentId2units = {}
	for unit in m_playerUnits:
		if not agentId2units.has( unit[OWNER] ):
			agentId2units[ unit[OWNER] ] = []
			
		agentId2units[ unit[OWNER] ].append( unit[WEAKREF_].get_ref() )
	
	for agentId in agentId2units:
		var agentNode = get_node( str(agentId) )
		if agentNode:
			agentNode.unassignUnits( agentId2units[agentId] )


func _registerCommands():
	if not is_network_master():
		return

	Console.register('unassignUnits', {
		'description' : "unassigns all player units",
		'target' : [self, '_unassignAllUnits']
	} )


func _unregisterCommands():	
	Console.deregister('unassignUnits')

	
	