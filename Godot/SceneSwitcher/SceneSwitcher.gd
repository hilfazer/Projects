extends Node

var _sceneParams = null                setget deleted
var _paramsLocked = true               setget deleted


func deleted(_a):
	assert(false)


signal sceneInstanced( scene ) # it won't be emitted if switchSceneToInstance() was used
signal sceneSetAsCurrent()
signal sceneReady( scene ) # in 3.1 there will be 'ready' signal in Node so this signal won't be needed


func switchScene( targetScenePath : String, params = null, meta = null ):
	# The way around this is deferring the load to a later time, when
	# it is ensured that no code from the current scene is running:
	call_deferred("_deferredSwitchScene", targetScenePath, params, "_nodeFromPath", meta )


func switchSceneTo( packedScene : PackedScene, params = null, meta = null ):
	call_deferred("_deferredSwitchScene", packedScene, params, "_nodeFromPackedScene", meta )


func switchSceneToInstance( node : Node, params = null, meta = null ):
	call_deferred("_deferredSwitchScene", node, params, "_returnArgument", meta )


func reloadCurrentScene():
	var sceneFilename = get_tree().current_scene.filename
	if sceneFilename.empty():
		return ERR_CANT_CREATE
	else:
		call_deferred("_deferredSwitchScene", sceneFilename, _sceneParams, "_nodeFromPath")


func getParams():
	var returnValue = _sceneParams if not _paramsLocked else null
	_paramsLocked = true
	return returnValue


func _deferredSwitchScene( sceneSource, params, nodeExtractionFunc, meta ):
	if sceneSource == null:
		_setParams( null )
		if get_tree().current_scene:
			get_tree().current_scene.free()
		assert( get_tree().current_scene == null )
		return

	_setParams( params )
	var newScene : Node = call( nodeExtractionFunc, sceneSource )
	if not newScene:
		_setParams( null )
		return      # if instancing a scene failed current_scene will not change


	if meta != null:
		assert( typeof(meta) == TYPE_STRING )
		newScene.set_meta( meta, params )

	if not sceneSource is Node:
		emit_signal( "sceneInstanced", newScene )

	if get_tree().current_scene:
		get_tree().current_scene.free()
	assert( get_tree().current_scene == null )

	# Make it a current scene between its "_enter_tree()" and "_ready()" calls
# warning-ignore:return_value_discarded
	newScene.connect("tree_entered", self, "_setAsCurrent", [newScene], CONNECT_ONESHOT)

	# Add it to the active scene, as child of root
	$"/root".add_child( newScene )
	assert( $"/root".has_node( newScene.get_path() ) )
	emit_signal( "sceneReady", newScene )


func _setAsCurrent( scene ):
	get_tree().set_current_scene( scene )
	assert( get_tree().current_scene == scene )
	emit_signal("sceneSetAsCurrent")


func _nodeFromPath( path ) -> Node:
	var node = ResourceLoader.load( path )
	return node.instance() if node else null


func _nodeFromPackedScene( packedScene ) -> Node:
	return packedScene.instance() if packedScene.can_instance() else null


func _returnArgument( node : Node ) -> Node:
	return node


func _setParams( params ):
	_sceneParams = params
	_paramsLocked = false
