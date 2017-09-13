extends Panel


const UnitLineScn = "res://gui/UnitLine.tscn"
const ModuleBase = "res://modules/Module.gd"

var m_units = []
var m_module


func _ready():
	moduleSelected( get_node("ModuleSelection/FileName").text )


func refreshLobby():
	var players = gamestate.m_players

	get_node("Players/PlayerList").clear()
	for p in players:
		var playerString = players[p] + " (" + str(p) + ") "
		playerString += " (You)" if p == get_tree().get_network_unique_id() else ""
		get_node("Players/PlayerList").add_item(playerString)


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
	displayUnit( m_units.size() - 1 )


func removeUnit( unitIdx ):
	pass


func displayUnit( unitIdx ):
	var unitLine = load(UnitLineScn).instance()
	unitLine.get_node("Name").set_text( m_units[unitIdx][0] )
	unitLine.get_node("Owner").set_text( str( m_units[unitIdx][1] ) )
	
	get_node("Players/Scroll/UnitList").add_child(unitLine)
	
	
func createCharacter():
	addUnit( get_node("UnitChoice").get_item_text( get_node("UnitChoice").get_selected() ),
		get_tree().get_network_unique_id() )
