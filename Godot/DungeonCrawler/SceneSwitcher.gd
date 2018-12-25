extends Node

var m_sceneParams = null               setget deleted, getParams


func deleted(_a):
	assert(false)


signal sceneSetAsCurrent()
signal sceneInstanced( scene )


func switchScene( targetScenePath, params = null ):
	# The way around this is deferring the load to a later time, when
	# it is ensured that no code from the current scene is running:
	call_deferred( "_deferredSwitchScene", targetScenePath, params, "_nodeFromPath" )
	
	
func switchSceneTo( packedScene, params = null ):
	call_deferred( "_deferredSwitchScene", packedScene, params, "_nodeFromPackedScene" )


func getParams():
	return m_sceneParams


func _deferredSwitchScene( sceneSource, params, nodeExtractionFunc ):
	if sceneSource == null:
		m_sceneParams = null
		if get_tree().current_scene:
			get_tree().current_scene.free()
		assert( get_tree().current_scene == null )
		return

	var newScene = call( nodeExtractionFunc, sceneSource )
	if newScene:
		m_sceneParams = params
		emit_signal( "sceneInstanced", newScene )
	else:
		m_sceneParams = null
		return       # if instancing a scene failed current_scene will not change

	if get_tree().current_scene:
		get_tree().current_scene.free()
	assert( get_tree().current_scene == null )


	# Make it a current scene between its "_enter_tree()" and "_ready()" calls
	newScene.connect("tree_entered", self, "_setAsCurrent", [newScene], CONNECT_ONESHOT)

	# Add it to the active scene, as child of root
	get_tree().get_root().add_child( newScene )


func _setAsCurrent( scene ):
	get_tree().set_current_scene( scene )
	assert( get_tree().current_scene == scene )
	emit_signal( "sceneSetAsCurrent" )
	
	
func _nodeFromPath( path ):
	var node = ResourceLoader.load( path )
	return node.instance() if node else null
	
	
func _nodeFromPackedScene( packedScene ):
	return packedScene.instance() if packedScene.can_instance() else null
	
	