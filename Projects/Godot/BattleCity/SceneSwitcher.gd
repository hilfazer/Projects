extends Node

var m_sceneParams = null setget setParams,getParams


func switchScene(targetScenePath, params = null):
	setParams(params)
	get_tree().change_scene(targetScenePath)


func getParams():
	var params = m_sceneParams
	m_sceneParams = null
	return params


func setParams(params):
	m_sceneParams = params
