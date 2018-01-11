extends Control

const ModuleBase = "res://modules/Module.gd"

const ModuleExtensions = ["gd"]

var m_params = {}
var m_previousSceneFile
var m_module_


signal tryDelete()
signal readyForGame( module_, playerUnitCreationData )


func _ready():
	m_previousSceneFile = SceneSwitcher.m_previousSceneFile
	m_params = SceneSwitcher.m_sceneParams
	assert(m_params != null)

	Connector.connectHostNewGame( self )

	if m_params["isHost"] == true:
		Network.hostGame( m_params["ip"], m_params["playerName"] )
		get_node("ModuleSelection/SelectModule").disabled = false
	else:
		Network.joinGame( m_params["ip"], m_params["playerName"] )

	moduleSelected( get_node("ModuleSelection/FileName").text )
	get_node("Lobby").setModule(m_module_)
	get_node("Lobby").connect("unitNumberChanged", self, "onUnitNumberChanged")


func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		if m_module_ != null:
			m_module_.free()


func _input(event):
	if event.is_action_pressed("ui_cancel"):
		emit_signal("tryDelete")
		accept_event()


func onLeaveGamePressed():
	Network.endConnection()
	SceneSwitcher.switchScene(m_previousSceneFile)


func onNetworkError( what ):
	SceneSwitcher.switchScene(m_previousSceneFile)


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

	m_module_ = moduleNode
	get_node("ModuleSelection/FileName").text = modulePath
	get_node("Lobby").setMaxUnits( m_module_.getPlayerUnitMax() )

	if Network.isServer():
		for playerId in Network.m_players:
			if playerId != get_tree().get_network_unique_id():
				sendToClient(playerId)


func onUnitNumberChanged( number ):
	assert( number >= 0 )
	get_node("Buttons/StartGame").disabled = ( number == 0 or !Network.isServer() )


func clear():
	get_node("ModuleSelection/FileName").text = "..." 
	if m_module_:
		m_module_.free()
		m_module_ = null

	get_node("Lobby").clearUnits()


func onStartGamePressed():
	emit_signal("readyForGame", m_module_, $"Lobby".m_unitsCreationData)
	m_module_ = null
