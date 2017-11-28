extends Panel

const GameGd = preload("res://modules/Game.gd")

const UnitLineScn = "res://gui/UnitLine.tscn"
const CharacterCreationScn = "res://gui/CharacterCreation.tscn"
const ModuleBase = "res://modules/Module.gd"

const ModuleExtensions = ["gd"]

var m_module
var m_units = []
var m_maxUnits
var m_characterCreationWindow


signal readyForGame( module, playerUnits )


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


func clear():
	m_units.clear()
	for child in get_node("Players/Scroll/UnitList").get_children():
		child.queue_free()

	m_maxUnits = 0


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


func sendToClient(id):
	assert( get_tree().is_network_server() )
	if id != get_tree().get_network_unique_id():
		rpc_id(id, "receiveState", m_units)


slave func receiveState( units ):
	assert( not get_tree().is_network_server() )
	assert( m_units.size() == 0 )

	for unit in units:
		addUnit( unit[GameGd.PATH], unit[GameGd.OWNER] )


func onCreateCharacterPressed():
	if m_characterCreationWindow != null:
		return
	
	m_characterCreationWindow = preload(CharacterCreationScn).instance()
	add_child(m_characterCreationWindow)
	m_characterCreationWindow.connect("tree_exited", self, "removeCharacterCreationWindow")
	
	
	
func removeCharacterCreationWindow():
	if not m_characterCreationWindow.is_queued_for_deletion():
		m_characterCreationWindow.queue_free()

	m_characterCreationWindow = null
	

