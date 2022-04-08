extends Node


signal scene_instanced( scene ) # it won't be emitted if switch_scene_to_instance() was used
signal scene_set_as_current()


var _param_handler: IParamsHandler = NullHandler.new()


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

	call_deferred("_deferred_switch_scene", scene_filename, _param_handler.params, \
			"_node_from_path", _param_handler.meta_key )
	return OK


func get_params( node: Node ):
	if node != _param_handler.scene:
		return null

	if _param_handler.meta_key != null:
		print( "SceneSwitcher: Parameters for %s '%s' available through metadata key: %s" \
				% [ node, node.name, _param_handler.meta_key ] )

	return _param_handler.params


func _deferred_switch_scene( scene_source, params, node_extraction_func, meta ):
	if scene_source == null:
		_param_handler = NullHandler.new()
		if get_tree().current_scene:
			get_tree().current_scene.free()
		assert( get_tree().current_scene == null )
		return

	var new_scene: Node = call( node_extraction_func, scene_source )
	if not new_scene:
		_param_handler = NullHandler.new()
		return      # if instancing a scene failed current_scene will not change

	if meta != null:
		assert( typeof(meta) == TYPE_STRING )
		new_scene.set_meta( meta, params )

	_param_handler = ParamsHandler.new( params, new_scene, meta )

	if not scene_source is Node:
		emit_signal( "scene_instanced", new_scene )

	if get_tree().current_scene:
		get_tree().current_scene.free()
	assert( get_tree().current_scene == null )

	# Make it a current scene between its "_enter_tree()" and "_ready()" calls
# warning-ignore:return_value_discarded
	new_scene.connect("tree_entered", self, "_set_as_current", [new_scene], CONNECT_ONESHOT)

	# Add it to the active scene, as child of root
	$"/root".add_child( new_scene )
	assert( $"/root".has_node( new_scene.get_path() ) )


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


class IParamsHandler extends Reference:
	pass


class NullHandler extends IParamsHandler:
	var params = null
	var scene = null
	var meta_key = null


class ParamsHandler extends IParamsHandler:
	var params
	var scene: Node
	var meta_key   # String or null

	func _init( parameters, scene_node: Node, metadata_key ):
		assert( scene_node )
		params = parameters
		scene = scene_node
		if metadata_key == null:
			return
		else:
			assert( metadata_key is String, "metadata key needs to be either null or String" )
			assert( scene.has_meta( metadata_key ) )
			meta_key = metadata_key
