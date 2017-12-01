extends Panel

const GameGd = preload("res://modules/Game.gd")

const UnitLineScn = "res://gui/UnitLine.tscn"
const CharacterCreationScn = "res://gui/CharacterCreation.tscn"
const ModuleBase = "res://modules/Module.gd"

const ModuleExtensions = ["gd"]

var m_module setget setModule
var m_unitsCreationData = []    setget deleted, deleted  # array of dicts
var m_maxUnits
var m_characterCreationWindow


signal readyForGame( module, playerUnits )


func deleted():
	assert(false)


func refreshLobby( playerIds ):
	get_node("Players/PlayerList").clear()
	for pId in playerIds:
		var playerString = playerIds[pId] + " (" + str(pId) + ") "
		playerString += " (You)" if pId == get_tree().get_network_unique_id() else ""
		get_node("Players/PlayerList").add_item(playerString)

	releaseUnownedUnits(playerIds)

	if not is_network_master():
		return

	for pId in playerIds:
		if pId != get_tree().get_network_unique_id():
			sendToClient(pId)


func releaseUnownedUnits( playerIds ):
	for i in range( m_unitsCreationData.size() ):
		if not m_unitsCreationData[i]["owner"] in playerIds:
			get_node("Players/Scroll/UnitList").get_child(i).release( m_unitsCreationData[i]["owner"] )


func clear():
	m_unitsCreationData.clear()
	for child in get_node("Players/Scroll/UnitList").get_children():
		child.queue_free()

	m_maxUnits = 0


slave func addUnit( creationData ):
	if (m_unitsCreationData.size() >= m_maxUnits):
		return false
	else:
		m_unitsCreationData.append( creationData )
		return addUnitLine( m_unitsCreationData.size() - 1 )


master func requestAddUnit( creationData ):
	if ( addUnit( creationData ) ):
		rpc("addUnit", creationData )


func addUnitLine( unitIdx ):
	var unitLine = load(UnitLineScn).instance()
	unitLine.initialize( unitIdx, m_unitsCreationData[unitIdx]["owner"] )
	unitLine.setUnit( m_unitsCreationData[unitIdx]["path"] )
	
	get_node("Players/Scroll/UnitList").add_child(unitLine)
	unitLine.connect("deletePressed", self, "onDeleteUnit")
	return true
	
	
func createCharacter( creationData ):
	if is_network_master():
		if ( addUnit( creationData ) ):
			rpc("addUnit", creationData )
	else:
		rpc_id(get_network_master(), "requestAddUnit", creationData )


slave func removeUnit( unitIdx ):
	m_unitsCreationData.remove( unitIdx )
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
		rpc_id(id, "receiveState", m_unitsCreationData)


slave func receiveState( units ):
	assert( not get_tree().is_network_server() )
	assert( m_unitsCreationData.size() == 0 )

	for unit in units:
		addUnit( unit )


func onCreateCharacterPressed():
	if m_characterCreationWindow != null:
		return
	
	m_characterCreationWindow = preload(CharacterCreationScn).instance()
	add_child(m_characterCreationWindow)
	m_characterCreationWindow.connect("tree_exited", self, "removeCharacterCreationWindow")
	m_characterCreationWindow.connect("madeCharacter", self, "createCharacter")
	m_characterCreationWindow.initialize(m_module)
	
	
func removeCharacterCreationWindow():
	if not m_characterCreationWindow.is_queued_for_deletion():
		m_characterCreationWindow.queue_free()

	m_characterCreationWindow = null
	

func setModule( module ):
	m_module = module
	
	
