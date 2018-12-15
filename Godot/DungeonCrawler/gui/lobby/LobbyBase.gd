extends Panel



var m_maxUnits = 0       setget setMaxUnits
var m_rpcTargets = []    setget setRpcTargets


func deleted(_a):
	assert(false)


func _ready():
	if not is_network_master():
		rpc( "sendState", get_tree().get_network_unique_id() )
	refreshLobby( Network.m_clients )


func setRpcTargets( clientIds ):
	m_rpcTargets = clientIds


func refreshLobby( players ):
	get_node("Players/PlayerList").clear()
	for pId in players:
		var playerString = players[pId] + " (" + str(pId) + ") "
		playerString += " (You)" if pId == get_tree().get_network_unique_id() else ""
		get_node("Players/PlayerList").add_item(playerString)


master func sendState(id):
	assert( id != get_tree().get_network_unique_id() )
	sendToClient(id)


func sendToClient(id):
	assert(not "implemented")


func setMaxUnits( maxUnits ):
	m_maxUnits = maxUnits
	get_node("UnitLimit").setMaximum(maxUnits)