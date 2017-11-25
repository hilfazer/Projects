extends Control

var m_params = {}
var m_previousScene

signal tryDelete


func _ready():
	m_previousScene = SceneSwitcher.m_previousScene
	m_params = SceneSwitcher.m_sceneParams
	assert(m_params != null)

	Connector.connectHostNewGame( self )

	if m_params["host"] == true:
		Network.hostGame( m_params["ip"], m_params["playerName"] )
	else:
		Network.joinGame( m_params["ip"], m_params["playerName"] )


func _input(event):
	if event.is_action_pressed("ui_cancel"):
		emit_signal("tryDelete")
		accept_event()


func onLeaveGamePressed():
	Network.endGame()
	SceneSwitcher.switchScene(m_previousScene)


func onNetworkError( what ):
	SceneSwitcher.switchScene(m_previousScene)
	
	