extends Node


signal scene_instanced( scene ) # it won't be emitted if switch_scene_to_instance() was used
signal scene_set_as_current()


var _param_handler: ParamsHandler = null


func switch_scene( target_scene_path: String, params = null, meta = null ):
	call_deferred("_deferred_switch_scene", target_scene_path, params, "_node_from_path", meta )


func switch_scene_to( packed_scene: PackedScene, params = null, meta = null ):
	call_deferred("_deferred_switch_scene", packed_scene, params, "_node_from_packed_scene", meta )


func switch_scene_to_instance( node: Node, params = null, meta = null ):
	call_deferred("_deferred_switch_scene", node, params, "_return_argument", meta )


func reload_current_scene() -> int:
	var scene_filename = get_tree().current_scene.filename
	if scene_filename.empty():
		return ERR_CANT_CREATE

	call_deferred("_deferred_switch_scene", scene_filename, _param_handler._params, \
			"_node_from_path", _param_handler._meta )
	return OK


func get_params( node: Node ):
	if not _param_handler or node != _param_handler._scene:
		return null

	if _param_handler._meta != null:
		print( "SceneSwitcher: Parameters for %s '%s' available through metadata key: %s" \
				% [ node, node.name, _param_handler._meta ] )

	return _param_handler._params


func _deferred_switch_scene( sceneSource, params, nodeExtractionFunc, meta ):
	if sceneSource == null:
		_param_handler = null
		if get_tree().current_scene:
			get_tree().current_scene.free()
		assert( get_tree().current_scene == null )
		return

	var newScene : Node = call( nodeExtractionFunc, sceneSource )
	if not newScene:
		_param_handler = null
		return      # if instancing a scene failed current_scene will not change

	if meta != null:
		assert( typeof(meta) == TYPE_STRING )
		newScene.set_meta( meta, params )

	_param_handler = ParamsHandler.new( params, newScene, meta )

	if not sceneSource is Node:
		emit_signal( "scene_instanced", newScene )

	if get_tree().current_scene:
		get_tree().current_scene.free()
	assert( get_tree().current_scene == null )

	# Make it a current scene between its "_enter_tree()" and "_ready()" calls
# warning-ignore:return_value_discarded
	newScene.connect("tree_entered", self, "_set_as_current", [newScene], CONNECT_ONESHOT)

	# Add it to the active scene, as child of root
	$"/root".add_child( newScene )
	assert( $"/root".has_node( newScene.get_path() ) )


func _set_as_current( scene ):
	get_tree().set_current_scene( scene )
	assert( get_tree().current_scene == scene )
	emit_signal("scene_set_as_current")


static func _node_from_path( path ) -> Node:
	var node = ResourceLoader.load( path )
	return node.instance() if node else null


static func _node_from_packed_scene( packed_scene ) -> Node:
	return packed_scene.instance() if packed_scene.can_instance() else null


static func _return_argument( node: Node ) -> Node:
	return node


class ParamsHandler extends Reference:
	var _params
	var _scene: Node
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
