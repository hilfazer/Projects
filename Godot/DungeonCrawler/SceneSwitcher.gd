extends Node

var m_sceneParams = null     setget deleted, getParams
var m_previousSceneFile = null   setget deleted
var m_currentScene = null


func deleted():
	assert(false)


func _ready():
	var root = get_tree().get_root()
	m_currentScene = root.get_child( root.get_child_count() -1 )


func switchScene(targetScenePath, params = null):
	# The way around this is deferring the load to a later time, when
	# it is ensured that no code from the current scene is running:
	call_deferred("deferredSwitchScene", targetScenePath, params)


func deferredSwitchScene(targetScenePath, params):
	if targetScenePath == null:
		return

	m_previousSceneFile = get_tree().get_current_scene().get_filename()

	assert( m_sceneParams == null )
	m_sceneParams = params

	# Immediately free the current scene,
	# there is no risk here.
	m_currentScene.free()

	# Load new scene
	var newScene = ResourceLoader.load(targetScenePath)

	# Instance the new scene
	m_currentScene = newScene.instance()

	# Add it to the active scene, as child of root
	get_tree().get_root().add_child(m_currentScene)

	# optional, to make it compatible with the SceneTree.change_scene() API
	get_tree().set_current_scene( m_currentScene )


func getParams():
	var params = m_sceneParams
	m_sceneParams = null
	return params
