extends Panel


signal unitNumberChanged( unitNumber )


var m_maxUnits = 0              setget setMaxUnits
var m_rpcTargets = []    setget setRpcTargets


func deleted():
	assert(false)


func _ready():
	if not is_network_master():
		rpc( "sendState", get_tree().get_network_unique_id() )
	refreshLobby( Network.m_players )


func setRpcTargets( clientIds ):
	m_rpcTargets = clientIds


master func sendState(id):
	assert( id != get_tree().get_network_unique_id() )
	sendToClient(id)


func sendToClient(id):
	assert(not "implemented")


func setMaxUnits( maxUnits ):
	m_maxUnits = maxUnits
	get_node("UnitLimit").setMaximum(maxUnits)