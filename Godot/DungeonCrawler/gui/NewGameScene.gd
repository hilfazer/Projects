extends Control

const ModuleBase = "res://modules/Module.gd"

const ModuleExtensions = ["gd"]
const InvalidModuleString = "..."

var m_params = {}         setget deleted
var m_previousSceneFile   setget deleted
var m_module_             setget setModule
var m_rpcTargets = []     setget deleted


signal tryDelete()
signal readyForGame( module_, playerUnitCreationData )


func deleted():
	assert(false)


func _ready():
	m_params = SceneSwitcher.m_sceneParams
	assert(m_params != null)

	Connector.connectNewGameScene( self )

	moduleSelected( get_node("ModuleSelection/FileName").text )
	get_node("Lobby").connect("unitNumberChanged", self, "onUnitNumberChanged")

	if m_params["isHost"] == true:
		get_node("ModuleSelection/SelectModule").disabled = false

	Network.connect("nodeRegisteredClientsChanged", self, "onNodeRegisteredClientsChanged")
	Network.rpc( "registerNodeForClient", get_path() )


func _exit_tree():
		if get_tree().has_network_peer():
			Network.rpc( "unregisterNodeForClient", get_path() )


func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		if m_module_ != null:
			m_module_.free()


func _input(event):
	if event.is_action_pressed("ui_cancel"):
		emit_signal("tryDelete")
		accept_event()


func onNodeRegisteredClientsChanged( nodePath ):
	if nodePath == get_path():
		setRpcTargets( Network.m_nodesWithClients[nodePath] )


func setRpcTargets( clientIds ):
	m_rpcTargets = clientIds
	$"Lobby".setRpcTargets( clientIds )


func onLeaveGamePressed():
	Network.endConnection()


func onNetworkError( what ):
	Network.endConnection()


slave func moduleSelected( modulePath ):
	assert( modulePath == InvalidModuleString or modulePath.get_extension() in ModuleExtensions )
	clear()

	if modulePath in [InvalidModuleString, ModuleBase]:
		if Network.isServer():
			for id in m_rpcTargets:
				rpc_id(id, "moduleSelected", get_node("ModuleSelection/FileName").text )
		return


	var moduleNode = load(modulePath).new()
	if (not moduleNode is load(ModuleBase)):
		return

	setModule( moduleNode )
	get_node("ModuleSelection/FileName").text = modulePath
	get_node("Lobby").setMaxUnits( m_module_.getPlayerUnitMax() )

	if Network.isServer():
		for id in m_rpcTargets:
			rpc_id(id, "moduleSelected", get_node("ModuleSelection/FileName").text )


func onUnitNumberChanged( number ):
	assert( number >= 0 )
	get_node("Buttons/StartGame").disabled = ( number == 0 or !Network.isServer() )


func clear():
	get_node("ModuleSelection/FileName").text = InvalidModuleString
	setModule( null )
	get_node("Lobby").clearUnits()


func onStartGamePressed():
	emit_signal("readyForGame", m_module_, $"Lobby".m_unitsCreationData)
	m_module_ = null  # release ownership


func setModule( moduleNode ):
	Utility.setFreeing( m_module_ )
	m_module_ = moduleNode
	get_node("Lobby").setModule( moduleNode )
	


