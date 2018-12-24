extends Node

var m_sceneParams = null               setget deleted, getParams


func deleted(a):
	assert(false)


signal sceneSetAsCurrent()
signal sceneInstanced( scene )


func switchScene( targetScenePath, params = null ):
	# The way around this is deferring the load to a later time, when
	# it is ensured that no code from the current scene is running:
	call_deferred( "_deferredSwitchScene", targetScenePath, params )


func getParams():
	return m_sceneParams


func _deferredSwitchScene( targetScenePath, params ):
	var currentScene = get_tree().current_scene
	
	# Immediately free the current scene,
	# there is no risk here.
	if currentScene:
		currentScene.free()
	
	assert( get_tree().current_scene == null )
		
	if targetScenePath == null:
		m_sceneParams = null
		assert( params == null )
		return

	m_sceneParams = params

	# Load new scene
	var newScene = ResourceLoader.load( targetScenePath )

	# Instance the new scene
	newScene = newScene.instance()
	emit_signal( "sceneInstanced", newScene )

	# Add it to the active scene, as child of root
	get_tree().get_root().add_child( newScene )

	get_tree().set_current_scene( newScene )
	assert( get_tree().current_scene == newScene )
	emit_signal( "sceneSetAsCurrent" )
