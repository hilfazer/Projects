extends Node

var m_sceneParams = null     setget deleted
var m_previousScene = null   setget deleted


func deleted():
	assert(false)


func switchScene(targetScenePath, params = null):
	if targetScenePath == null:
		return

	m_sceneParams = params
	get_tree().change_scene(targetScenePath)
	m_previousScene = get_tree().get_current_scene().get_filename()



