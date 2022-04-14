extends Node


signal scene_instanced(scene) # it won't be emitted if switch_scene_to_instance() was used
signal scene_set_as_current()
signal progress_changed(progress)
signal faded_in()
signal faded_out()


const FADE_IN := "fade_in"
const FADE_OUT := "fade_out"
const MSG_WRONG_META_TYPE := "Metadata key needs to be either null or String"
const MSG_PARAMS_VIA_META := "SceneSwitcher: Parameters for %s '%s' available through metadata key: %s"
const MSG_NEW_SCENE_INVALID := "SceneSwitcher: New scene is invalid. Scene switch aborted"
const MSG_GET_PARAMS_BLOCKED := "SceneSwitcher: Node %s can't receive scene parameters"
const MSG_NODE_NOT_A_SCENE := "New scene's node (%s) isn't a scene"
const MSG_CANT_CREATE_THREAD := "SceneSwitcher: Couldn't create a thread"

enum State { READY, PREPARING, SWITCHING }

var play_animations := true setget set_play_animations

onready var _transition_player: AnimationPlayer = $"AnimationPlayer"
var _param_handler: IParamsHandler = NullHandler.new()

var _state: int = State.READY
#TODO move to single object
var _loader_thread := Thread.new()
var _params = null
var _meta = null
var _packed_scene: Resource


func switch_scene( scene_path: String, params = null, meta = null ):
	if not _state == State.READY:
		return ERR_BUSY

	assert( not _loader_thread.is_active() and not _loader_thread.is_alive() )

	var error = _loader_thread.start(self, "_packed_scene_from_path", scene_path)
	if error == ERR_CANT_CREATE:
		print(MSG_CANT_CREATE_THREAD)
		return ERR_CANT_CREATE

	_state = State.PREPARING
	_params = params
	_meta = meta
	if play_animations:
		_transition_player.play(FADE_IN)


func switch_scene_interactive( scene_path: String, params = null, meta = null ):
	if not _state == State.READY:
		return ERR_BUSY

	assert( not _loader_thread.is_active() and not _loader_thread.is_alive() )

	var error = _loader_thread.start(self, "_packed_scene_from_path_interactive", scene_path)
	if error == ERR_CANT_CREATE:
		print(MSG_CANT_CREATE_THREAD)
		return ERR_CANT_CREATE

	_state = State.PREPARING
	_params = params
	_meta = meta
	if play_animations:
		_transition_player.play(FADE_IN)


func switch_scene_to( packed_scene: PackedScene, params = null, meta = null ):
	if not _state == State.READY:
		return ERR_BUSY

	call_deferred("_deferred_switch_scene", packed_scene, params, "_node_from_packed_scene", meta )


func switch_scene_to_instance( node: Node, params = null, meta = null ):
	if not _state == State.READY:
		return ERR_BUSY

	call_deferred("_deferred_switch_scene", node, params, "_return_argument", meta )


func clear_scene():
	if not _state == State.READY:
		return ERR_BUSY

	yield(get_tree(), "idle_frame")
	_param_handler = NullHandler.new()
	get_tree().current_scene.free()
	get_tree().current_scene = null


func reload_current_scene() -> int:
	if not _state == State.READY:
		return ERR_BUSY

	var scene_filename = get_tree().current_scene.filename
	if scene_filename.empty():
		return ERR_CANT_CREATE

#	call_deferred("_deferred_switch_scene", scene_filename, _param_handler.params, \
#			"_node_from_path", _param_handler.meta_key )
	return OK


# pass 'self' for the argument
func get_params( node: Node ):
	if node != _param_handler.scene:
		print(MSG_GET_PARAMS_BLOCKED % [node.name])
		return null

	if _param_handler.meta_key != null:
		print( MSG_PARAMS_VIA_META % [ node, node.name, _param_handler.meta_key ] )

	return _param_handler.params


func set_play_animations( play : bool ):
	play_animations = play

#-------------------------------------------------------------------------------

func _load_finished( packed_scene: Resource ):
	_loader_thread.wait_to_finish()

	if packed_scene == null:
		print(MSG_NEW_SCENE_INVALID)
		_transition_player.stop(true)
		_state = State.READY
		return

	assert(_state == State.PREPARING)
	_packed_scene = packed_scene
	_try_switching()


func _deferred_switch_scene( scene_source, params, node_extraction_func: String, meta ):
	assert(scene_source != null)
	assert(_state == State.SWITCHING)

	if scene_source is Node:
		assert(not scene_source.filename.empty(), MSG_NODE_NOT_A_SCENE % [scene_source.name])

	var new_scene: Node = call( node_extraction_func, scene_source )
	if not is_instance_valid(new_scene):
		_param_handler = NullHandler.new()
		print_debug(MSG_NEW_SCENE_INVALID)
		return      # if instancing a scene failed current_scene will not change

	if meta != null:
		assert( meta is String, MSG_WRONG_META_TYPE )
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
	if play_animations:
		_transition_player.play(FADE_OUT)
	_state = State.READY


func _set_as_current( scene: Node ):
	get_tree().set_current_scene( scene )
	assert( get_tree().current_scene == scene )
	emit_signal("scene_set_as_current")


func _packed_scene_from_path( path: String ) -> void:
	call_deferred("_load_finished", ResourceLoader.load( path ) )


func _node_from_path( path: String ) -> void:
	var node = ResourceLoader.load( path )
	call_deferred("_load_finished", node.instance() if node else null)


func _packed_scene_from_path_interactive( path: String ) -> void:
	var SIMULATED_DELAY_SEC = 0.3
	var ril = ResourceLoader.load_interactive( path )
	assert(ril)
	var total = ril.get_stage_count()

	var res: PackedScene = null

	while true: #iterate until we have a resource
		print( ril.get_stage() )
		# Update progress bar, use call deferred, which routes to main thread.
		emit_signal("progress_changed", 100.0 * ril.get_stage() / total)
		#progress.call_deferred("set_value", ril.get_stage())

		# Simulate a delay.
		OS.delay_msec(int(SIMULATED_DELAY_SEC * 1000.0))

		# Poll (does a load step).
		var err = ril.poll()

		# If OK, then load another one. If EOF, it' s done. Otherwise there was an error.
		if err == ERR_FILE_EOF:
			# Loading done, fetch resource.
			res = ril.get_resource()
			emit_signal("progress_changed", 100.0)
			break
		elif err != OK:
			# Not OK, there was an error.
			print("There was an error loading")
			break

	call_deferred("_load_finished", res.instance() if res != null else null)


func _try_switching():
	assert(_state == State.PREPARING)

	if _transition_player.current_animation == FADE_IN:
		return

	if _loader_thread.is_active():
		return

	_state = State.SWITCHING
	call_deferred( \
			"_deferred_switch_scene", _packed_scene, _params, "_node_from_packed_scene", _meta)


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == FADE_IN:
		emit_signal("faded_in")
		_try_switching()
	elif anim_name == FADE_OUT:
		emit_signal("faded_out")


static func _node_from_packed_scene( packed_scene: PackedScene ) -> Node:
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
		assert(scene_node)
		params = parameters
		scene = scene_node
		if metadata_key == null:
			return
		else:
			assert( metadata_key is String, MSG_WRONG_META_TYPE )
			assert( scene.has_meta( metadata_key ) )
			meta_key = metadata_key

