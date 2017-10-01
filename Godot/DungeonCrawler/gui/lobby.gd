extends Panel

const GameGd = preload("res://modules/Game.gd")

const UnitLineScn = "res://gui/UnitLine.tscn"
const ModuleBase = "res://modules/Module.gd"

const ModuleExtensions = ["gd"]

var m_module
#enum UnitFields {PATH = 0, OWNER = 1}
var m_units = []
var m_maxUnits


signal readyForGame( module, playerUnits )


func _ready():
	moduleSelected( get_node("ModuleSelection/FileName").text )


func refreshLobby( playerIds ):
	get_node("Players/PlayerList").clear()
	for p in playerIds:
		var playerString = playerIds[p] + " (" + str(p) + ") "
		playerString += " (You)" if p == get_tree().get_network_unique_id() else ""
		get_node("Players/PlayerList").add_item(playerString)

	releaseUnownedUnits(playerIds)


func releaseUnownedUnits( playerIds ):
	for i in range( m_units.size() ):
		if not m_units[i][GameGd.OWNER] in playerIds:
			get_node("Players/Scroll/UnitList").get_child(i).release( m_units[i][GameGd.OWNER] )


slave func moduleSelected( modulePath ):
	assert( modulePath.get_extension() in ModuleExtensions )
	clear()
	if Network.isServer():
		rpc("moduleSelected", get_node("ModuleSelection/FileName").text)

	if modulePath == ModuleBase:
		return

	var moduleNode = load(modulePath).new()
	if (not moduleNode is load(ModuleBase)):
		return

	m_module = moduleNode
	get_node("ModuleSelection/FileName").text = modulePath

	m_maxUnits = m_module.getPlayerUnitMax()

	for unitPath in m_module.getUnitsForCreation():
		get_node("UnitChoice").add_item(unitPath)

	get_node("CreateUnit").disabled = false
	
	if Network.isServer():
		for playerId in Network.m_players:
			if playerId != get_tree().get_network_unique_id():
				sendToClient(playerId)


func clear():
	get_node("ModuleSelection/FileName").text = "..." 
	if m_module:
		m_module.free()
		m_module = null
	m_units.clear()
	for child in get_node("Players/Scroll/UnitList").get_children():
		child.queue_free()
		
	m_maxUnits = 0
	
	get_node("UnitChoice").clear()
	get_node("CreateUnit").disabled = true


slave func addUnit( filePath, ownerId ):
	if (m_units.size() >= m_maxUnits):
		return false
	else:
		m_units.append( [filePath, ownerId] )
		return addUnitLine( m_units.size() - 1 )


master func requestAddUnit( filePath, ownerId ):
	if ( addUnit( filePath, ownerId ) ):
		rpc("addUnit", filePath, ownerId )


func addUnitLine( unitIdx ):
	var unitLine = load(UnitLineScn).instance()
	unitLine.initialize( unitIdx, m_units[unitIdx][GameGd.OWNER] )
	unitLine.setUnit( m_units[unitIdx][GameGd.PATH] )
	
	get_node("Players/Scroll/UnitList").add_child(unitLine)
	unitLine.connect("deletePressed", self, "onDeleteUnit")
	return true
	
	
func createCharacter():
	var unitName = get_node("UnitChoice").get_item_text( get_node("UnitChoice").get_selected() )
	var unitOwner = 0 if not get_tree().has_network_peer() else get_tree().get_network_unique_id()
	if (not unitOwner in Network.m_players):
		return

	if Network.isServer():
		if ( addUnit( unitName, unitOwner ) ):
			rpc("addUnit", unitName, unitOwner )
	else:
		rpc("requestAddUnit", unitName, unitOwner )


slave func removeUnit( unitIdx ):
	m_units.remove( unitIdx )
	get_node("Players/Scroll/UnitList").get_child( unitIdx ).queue_free()


master func requestRemoveUnit( unitIdx ):
	assert( is_network_master() )
	# todo: check if request comes from unit owner
	removeUnit( unitIdx )
	rpc("removeUnit", unitIdx )


func onDeleteUnit( unitIdx ):
	if Network.isServer():
		removeUnit( unitIdx )
		rpc("removeUnit", unitIdx )
	else:
		rpc("requestRemoveUnit", unitIdx)


func onNetworkPeerChanged():
	var isServer = Network.isServer()
	get_node("ModuleSelection/SelectModule").disabled = !isServer
	get_node("ModuleSelection/LoadModule").disabled = !isServer
	get_node("StartGame").disabled = !isServer
	
	
func sendToClient(id):
	assert( get_tree().is_network_server() )
	if id != get_tree().get_network_unique_id():
		rpc_id(id, "receiveState", get_node("ModuleSelection/FileName").text, m_units)


slave func receiveState( modulePath, units ):
	assert( not get_tree().is_network_server() )
	moduleSelected( modulePath )
	assert( m_units.size() == 0 )

	for unit in units:
		addUnit( unit[GameGd.PATH], unit[GameGd.OWNER] )


func onStartGamePressed():
	assert( m_module != null )
	emit_signal("readyForGame", m_module, m_units)
