extends Panel


const UnitLineScn = "res://gui/UnitLine.tscn"
const ModuleBase = "res://modules/Module.gd"

var m_units = []
var m_module


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


func clear():
	get_node("ModuleSelection/FileName").text = "..."
	if m_module:
		m_module.queue_free()
		m_module = null
	m_units.clear()
	for child in get_node("Players/Scroll/UnitList").get_children():
		child.queue_free()
		

func addUnit( filePath, ownerId ):
	m_units.append( [filePath, ownerId] )
	displayUnit( m_units.size() - 1 )


func displayUnit( unitIdx ):
	pass