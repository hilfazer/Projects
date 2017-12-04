extends Control

const ModuleBase = "res://modules/Module.gd"

const ModuleExtensions = ["gd"]

var m_params = {}
var m_previousScene
var m_module


func _ready():
	m_previousScene = SceneSwitcher.m_previousScene
	m_params = SceneSwitcher.m_sceneParams
	assert(m_params != null)

	Connector.connectHostNewGame( self )

	if m_params["host"] == true:
		Network.hostGame( m_params["ip"], m_params["playerName"] )
		get_node("ModuleSelection/SelectModule").disabled = false
	else:
		Network.joinGame( m_params["ip"], m_params["playerName"] )

	moduleSelected( get_node("ModuleSelection/FileName").text )
	get_node("Lobby").setModule(m_module)
	get_node("Lobby").connect("unitNumberChanged", self, "onUnitNumberChanged")


func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		if m_module != null:
			m_module.free()


func _input(event):
	if event.is_action_pressed("ui_cancel"):
		emit_signal("tryDelete")
		accept_event()


func onLeaveGamePressed():
	Network.endGame()
	SceneSwitcher.switchScene(m_previousScene)


func onNetworkError( what ):
	SceneSwitcher.switchScene(m_previousScene)
	
	
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
	get_node("Lobby").setMaxUnits( m_module.getPlayerUnitMax() )

	if Network.isServer():
		for playerId in Network.m_players:
			if playerId != get_tree().get_network_unique_id():
				sendToClient(playerId)


func onUnitNumberChanged( number ):
	assert( number >= 0 )
	get_node("Buttons/StartGame").disabled = ( number == 0 or !Network.isServer() )


func clear():
	get_node("ModuleSelection/FileName").text = "..." 
	if m_module:
		m_module.free()
		m_module = null

	get_node("Lobby").clearUnits()
	
	
	