extends Node


var _paramHandler : ParamsHandler = null


signal sceneInstanced( scene ) # it won't be emitted if switchSceneToInstance() was used
signal sceneSetAsCurrent()


func switchScene( targetScenePath : String, params = null, meta = null ):
	call_deferred("_deferredSwitchScene", targetScenePath, params, "_nodeFromPath", meta )


func switchSceneTo( packedScene : PackedScene, params = null, meta = null ):
	call_deferred("_deferredSwitchScene", packedScene, params, "_nodeFromPackedScene", meta )


func switchSceneToInstance( node : Node, params = null, meta = null ):
	call_deferred("_deferredSwitchScene", node, params, "_returnArgument", meta )


func reloadCurrentScene() -> int:
	var sceneFilename = get_tree().current_scene.filename
	if sceneFilename.empty():
		return ERR_CANT_CREATE

	call_deferred("_deferredSwitchScene", sceneFilename, _paramHandler._params, \
			"_nodeFromPath", _paramHandler._meta )
	return OK


func getParams( node : Node ):
	if not _paramHandler or node != _paramHandler._scene:
		return null

	if _paramHandler._meta != null:
		print( "SceneSwitcher: Parameters for %s '%s' available through metadata key: %s" \
				% [ node, node.name, _paramHandler._meta ] )

	return _paramHandler._params


func _deferredSwitchScene( sceneSource, params, nodeExtractionFunc, meta ):
	if sceneSource == null:
		_paramHandler = null
		if get_tree().current_scene:
			get_tree().current_scene.free()
		assert( get_tree().current_scene == null )
		return

	var newScene : Node = call( nodeExtractionFunc, sceneSource )
	if not newScene:
		_paramHandler = null
		return      # if instancing a scene failed current_scene will not change

	if meta != null:
		assert( typeof(meta) == TYPE_STRING )
		newScene.set_meta( meta, params )

	_paramHandler = ParamsHandler.new( params, newScene, meta )

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


func _setAsCurrent( scene ):
	get_tree().set_current_scene( scene )
	assert( get_tree().current_scene == scene )
	emit_signal("sceneSetAsCurrent")


static func _nodeFromPath( path ) -> Node:
	var node = ResourceLoader.load( path )
	return node.instance() if node else null


static func _nodeFromPackedScene( packedScene ) -> Node:
	return packedScene.instance() if packedScene.can_instance() else null


static func _returnArgument( node : Node ) -> Node:
	return node


class ParamsHandler extends Reference:
	var _params
	var _scene : Node
	var _meta   # String or null

	func _init( params, sceneNode, metaKey ):
		assert( sceneNode )
		_params = params
		_scene = sceneNode
		if metaKey == null:
			return
		else:
			assert( metaKey is String )
			assert( _scene.has_meta( metaKey ) )
			_meta = metaKey
