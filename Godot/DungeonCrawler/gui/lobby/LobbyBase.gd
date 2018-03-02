extends Panel


signal unitNumberChanged( unitNumber )


var m_maxUnits = 0              setget setMaxUnits


func deleted():
	assert(false)


func _ready():
	if not is_network_master():
		rpc( "sendState", get_tree().get_network_unique_id() )
	refreshLobby( Network.m_players )


master func sendState(id):
	assert( id != get_tree().get_network_unique_id() )
	sendToClient(id)


func sendToClient(id):
	assert(not "implemented")


func setMaxUnits( maxUnits ):
	m_maxUnits = maxUnits
	get_node("UnitLimit").setMaximum(maxUnits)