extends Node

const PlayerUnitGd           = preload("./PlayerUnit.gd")
const PlayerAgentGd          = preload("res://agents/PlayerAgent.gd")
const UtilityGd              = preload("res://Utility.gd")

enum UnitFields { NODE = PlayerUnitGd.NODE, \
				OWNER = PlayerUnitGd.OWNER, WEAKREF = PlayerUnitGd.WEAKREF }

var m_playerUnits = []                 setget deleted # setPlayerUnits


func deleted(a):
	assert(false)


func _ready():
	Connector.connectPlayerManager( self )
	onClientListChanged( Network.m_clients )


func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		for unit in m_playerUnits:
			if unit[WEAKREF].get_ref() != null:
				assert( unit[WEAKREF].get_ref() == unit[NODE] )
				assert( not unit[NODE].is_inside_tree() )
				unit[NODE].free()


func createPlayerUnits( unitsCreationData ):
	var playerUnits = []
	for unitData in unitsCreationData:
		var unitNode_ = load( unitData["path"] ).instance()
		unitNode_.set_name( str( Network.m_clients[unitData["owner"]] ) + "_" )
		unitNode_.setNameLabel( Network.m_clients[unitData["owner"]] )
		playerUnits.append( {OWNER : unitData["owner"], NODE : unitNode_, WEAKREF : weakref(unitNode_) } )

	setPlayerUnits( playerUnits )
	
	
func setPlayerUnits( playerUnits ):
	for unit in m_playerUnits:
		UtilityGd.setFreeing( unit[NODE] )

	m_playerUnits = playerUnits
	
	
func resetPlayerUnits( playerUnitsPaths ):
	setPlayerUnits( [] )

	var playerUnits = []
	for unitPath in playerUnitsPaths:
		var unit = {}
		unit[NODE] = get_tree().get_root().get_node( unitPath )
		unit[WEAKREF] = weakref( unit[NODE] )
		unit[OWNER] = get_tree().get_network_unique_id()
		unit[NODE].setNameLabel( Network.m_clients[unit[OWNER]] )
		playerUnits.append(unit)
		
	setPlayerUnits( playerUnits )
	assignAgentsToPlayerUnits()


func onClientListChanged( clientList ):
	pass


func assignAgentsToPlayerUnits():
	assert( is_network_master() )

	for unit in m_playerUnits:
		if unit[OWNER] == get_tree().get_network_unique_id():
			assignOwnAgent( unit[NODE].get_path() )
		else:
			rpc_id( unit[OWNER], "assignOwnAgent", unit[NODE].get_path() )


remote func assignOwnAgent( unitNodePath ):
	var unitNode = get_node( unitNodePath )
	assert( unitNode )
	var playerAgent = PlayerAgentGd.new()
	playerAgent.set_network_master( get_tree().get_network_unique_id() )
	playerAgent.assignToUnit( unitNode )


func getPlayerUnitNodes():
	var nodes = []
	for unit in m_playerUnits:
		if unit[WEAKREF] != null:
			assert( unit[OWNER] in Network.m_clients )
			nodes.append( unit[WEAKREF].get_ref() )

	return nodes