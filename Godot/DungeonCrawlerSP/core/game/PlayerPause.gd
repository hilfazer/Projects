extends Control

onready var m_pause = visible
onready var m_sceneRoot = $"../.."


func _input(event):
	if event.is_action_pressed("pause"):
		m_pause = !m_pause
		visible = m_pause
		m_sceneRoot.updatePaused()
