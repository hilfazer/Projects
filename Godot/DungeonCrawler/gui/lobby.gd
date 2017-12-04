extends Panel

const GameGd = preload("res://modules/Game.gd")

const UnitLineScn = "res://gui/UnitLine.tscn"
const CharacterCreationScn = "res://gui/CharacterCreation.tscn"
const ModuleBase = "res://modules/Module.gd"

const ModuleExtensions = ["gd"]

var m_module                    setget setModule
var m_unitsCreationData = []    setget deleted  # array of dicts
var m_maxUnits                  setget setMaxUnits
var m_characterCreationWindow   setget deleted


signal unitNumberChanged( unitNumber )


func deleted():
	assert(false)


func _ready():
	connect("unitNumberChanged", self, "onUnitNumberChanged")


func refreshLobby( playerIds ):
	get_node("Players/PlayerList").clear()
	for pId in playerIds:
		var playerString = playerIds[pId] + " (" + str(pId) + ") "
		playerString += " (You)" if pId == get_tree().get_network_unique_id() else ""
		get_node("Players/PlayerList").add_item(playerString)
		
	deleteUnownedUnits(playerIds)

	if not is_network_master():
		return

	for pId in playerIds:
		if pId != get_tree().get_network_unique_id():
			sendToClient(pId)


func deleteUnownedUnits( playerIds ):
	var indicesToRemove = []
	for unitIdx in range( m_unitsCreationData.size() ):
		if not m_unitsCreationData[unitIdx]["owner"] in playerIds:
			indicesToRemove.append( unitIdx )
	indicesToRemove.sort_custom(Utility, "greaterThan")

	for idx in indicesToRemove:
		removeUnit( idx )


func clearUnits():
	m_unitsCreationData.clear()
	for child in get_node("Players/Scroll/UnitList").get_children():
		child.queue_free()

	m_maxUnits = 0
	emit_signal("unitNumberChanged", m_unitsCreationData.size())


slave func addUnit( creationData ):
	if (m_unitsCreationData.size() >= m_maxUnits):
		return false
	else:
		m_unitsCreationData.append( creationData )
		emit_signal("unitNumberChanged", m_unitsCreationData.size())
		return addUnitLine( m_unitsCreationData.size() - 1 )


master func requestAddUnit( creationData ):
	if ( addUnit( creationData ) ):
		rpc("addUnit", creationData )


func addUnitLine( unitIdx ):
	var unitLine = load(UnitLineScn).instance()

	get_node("Players/Scroll/UnitList").add_child(unitLine)
	unitLine.initialize( unitIdx, m_unitsCreationData[unitIdx]["owner"] )
	unitLine.setUnit( m_unitsCreationData[unitIdx]["path"] )
	unitLine.connect("deletePressed", self, "onDeleteUnit")
	return true
	
	
func createCharacter( creationData ):
	if is_network_master():
		if ( addUnit( creationData ) ):
			rpc("addUnit", creationData )
	else:
		rpc("requestAddUnit", creationData )


slave func removeUnit( unitIdx ):
	m_unitsCreationData.remove( unitIdx )
	get_node("Players/Scroll/UnitList").get_child( unitIdx ).queue_free()
	emit_signal("unitNumberChanged", m_unitsCreationData.size())


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


slave func receiveState( unitsCreationData ):
	assert( not get_tree().is_network_server() )
	assert( m_unitsCreationData.size() == 0 )

	for creationData in unitsCreationData:
		addUnit( creationData )


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


func onUnitNumberChanged( unitNumber ):
	get_node("UnitLimit").setCurrent( m_unitsCreationData.size() )
	get_node("CreateCharacter").disabled = m_unitsCreationData.size() == m_maxUnits


func setModule( module ):
	m_module = module


func setMaxUnits( maxUnits ):
	m_maxUnits = maxUnits
	get_node("UnitLimit").setMaximum(maxUnits)
	get_node("CreateCharacter").disabled = m_unitsCreationData.size() == m_maxUnits

