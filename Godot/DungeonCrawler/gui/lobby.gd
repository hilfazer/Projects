extends Panel


const UnitLineScn = "res://gui/UnitLine.tscn"
const ModuleBase = "res://modules/Module.gd"

enum UnitFields {PATH = 0, OWNER = 1}
var m_units = []
var m_module


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
		if not m_units[i][OWNER] in playerIds:
			get_node("Players/Scroll/UnitList").get_child(i).release( m_units[i][OWNER] )


func moduleSelected( modulePath ):
	clear()
	if modulePath == ModuleBase:
		return

	var moduleScript = load(modulePath)

	if (not moduleScript or not moduleScript.new() is load(ModuleBase)):
		return

	m_module = moduleScript.new()
	get_node("ModuleSelection/FileName").text = modulePath

	for unitPath in m_module.getUnits():
		get_node("UnitChoice").add_item(unitPath)
		
	get_node("CreateUnit").disabled = false


func clear():
	get_node("ModuleSelection/FileName").text = "..."
	if m_module:
		m_module.queue_free()
		m_module = null
	m_units.clear()
	for child in get_node("Players/Scroll/UnitList").get_children():
		child.queue_free()
	
	get_node("UnitChoice").clear()
	get_node("CreateUnit").disabled = true


func addUnit( filePath, ownerId ):
	m_units.append( [filePath, ownerId] )
	addUnitLine( m_units.size() - 1 )


func removeUnit( unitIdx ):
	pass


func addUnitLine( unitIdx ):
	var unitLine = load(UnitLineScn).instance()
	unitLine.initialize( unitIdx, m_units[unitIdx][OWNER] )
	unitLine.setUnit( m_units[unitIdx][PATH] )
	
	get_node("Players/Scroll/UnitList").add_child(unitLine)
	
	
func createCharacter():
	addUnit(
		get_node("UnitChoice").get_item_text( get_node("UnitChoice").get_selected() ),
		0 if not get_tree().has_network_peer()
		else get_tree().get_network_unique_id()
	)
