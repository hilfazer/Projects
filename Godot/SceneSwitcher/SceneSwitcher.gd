extends Node

var m_sceneParams = null               setget deleted, getParams
var m_currentScene = null              setget deleted


func deleted(a):
	assert(false)


signal currentSceneChanged()
signal sceneInstanced( scene )


func _ready():
	var root = get_tree().get_root()
	m_currentScene = root.get_child( root.get_child_count() -1 )


func switchScene( targetScenePath, params = null ):
	m_sceneParams = null
	# The way around this is deferring the load to a later time, when
	# it is ensured that no code from the current scene is running:
	call_deferred( "_deferredSwitchScene", targetScenePath, params )


func getParams():
	return m_sceneParams


func _deferredSwitchScene( targetScenePath, params ):
	if targetScenePath == null:
		return

	assert( m_sceneParams == null )
	m_sceneParams = params

	# Immediately free the current scene,
	# there is no risk here.
	m_currentScene.free()

	# Load new scene
	var newScene = ResourceLoader.load( targetScenePath )

	# Instance the new scene
	m_currentScene = newScene.instance()
	emit_signal( "sceneInstanced", m_currentScene )

	# Add it to the active scene, as child of root
	get_tree().get_root().add_child( m_currentScene )

	# optional, to make it compatible with the SceneTree.change_scene() API
	get_tree().set_current_scene( m_currentScene )
	emit_signal( "currentSceneChanged" )

