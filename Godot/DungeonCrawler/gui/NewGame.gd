extends Control

var m_params = {}
var m_previousScene

signal tryDelete


func _ready():
	m_previousScene = SceneSwitcher.m_previousScene
	m_params = SceneSwitcher.m_sceneParams
	assert(m_params != null)


func _input(event):
	if event.is_action_pressed("ui_cancel"):
		emit_signal("tryDelete")
		accept_event()


func onLeaveGamePressed():
	SceneSwitcher.switchScene(m_previousScene)
	
