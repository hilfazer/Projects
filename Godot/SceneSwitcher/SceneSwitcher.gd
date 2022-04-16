extends Node


signal scene_instanced(scene) # it won't be emitted if switch_scene_to_instance() was used
signal scene_set_as_current()
signal progress_changed(progress)
signal faded_in()
signal faded_out()
#TODO abort_switch signal that returns parameters

const FADE_IN := "fade_in"
const FADE_OUT := "fade_out"
const MSG_WRONG_META_TYPE := "Metadata key needs to be either null or String"
const MSG_PARAMS_VIA_META := "SceneSwitcher: Parameters for %s '%s' available through metadata key: %s"
const MSG_NEW_SCENE_INVALID := "SceneSwitcher: New scene is invalid"
const MSG_GET_PARAMS_BLOCKED := "SceneSwitcher: Node %s can't receive scene parameters"
const MSG_NODE_NOT_A_SCENE := "New scene's node (%s) isn't a scene"
const MSG_CANT_CREATE_THREAD := "SceneSwitcher: Couldn't create a thread"

enum State { READY, PREPARING, SWITCHING }

var play_animations := true setget set_play_animations

onready var _transition_player: AnimationPlayer = $"AnimationPlayer"
var _param_handler: IParamsHandler = NullHandler.new()

var _state: int = State.READY
var _prep_state: SceneLoader


func switch_scene( scene_path: String, params = null, meta = null ) -> int:
	if not _state == State.READY:
		return ERR_BUSY

	assert( _prep_state == null )
	_prep_state = SceneLoader.new(self, params, meta)

	var error = _prep_state.start_load_from_path(scene_path)
	if error == ERR_CANT_CREATE:
		_abort_switch(MSG_CANT_CREATE_THREAD)
		return ERR_CANT_CREATE

	_state = State.PREPARING

	if play_animations:
		_transition_player.play(FADE_IN)
	return OK


func switch_scene_interactive( scene_path: String, params = null, meta = null ) -> int:
	if not _state == State.READY:
		return ERR_BUSY

	assert( _prep_state == null )
	_prep_state = SceneLoader.new(self, params, meta)

	var error = _prep_state.start_load_from_path_interactive(scene_path)
	if error == ERR_CANT_CREATE:
		_abort_switch(MSG_CANT_CREATE_THREAD)
		return ERR_CANT_CREATE

	_state = State.PREPARING

	if play_animations:
		_transition_player.play(FADE_IN)
	return OK


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

	assert( _prep_state == null )

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


func set_play_animations( play: bool ):
	play_animations = play

#-------------------------------------------------------------------------------

func _on_preperation_done():
	if _prep_state.packed_scene == null:
		_abort_switch(MSG_NEW_SCENE_INVALID)
		return

	assert(_state == State.PREPARING)
	_try_switching()


func _try_switching():
	assert(_state == State.PREPARING and _prep_state != null)

	if _transition_player.current_animation == FADE_IN:
		return

	if _prep_state.loader_thread.is_active():
		return

	call_deferred( \
			"_deferred_switch_scene",
			_prep_state.packed_scene,
			_prep_state.params,
			"_node_from_packed_scene",
			_prep_state.meta )
	_state = State.SWITCHING
	_prep_state = null


func _deferred_switch_scene( scene_source, params, node_extraction_func: String, meta ):
	assert(scene_source != null)
	assert(_state == State.SWITCHING)
	assert(_prep_state == null)

	if scene_source is Node:
		assert(not scene_source.filename.empty(), MSG_NODE_NOT_A_SCENE % [scene_source.name])

	var new_scene: Node = call( node_extraction_func, scene_source )
	if not is_instance_valid(new_scene):
		_param_handler = NullHandler.new()
		print(MSG_NEW_SCENE_INVALID)
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


func _abort_switch( message: String ) -> void:
	if message:
		print(message, ". Scene switch aborted")

	if play_animations:
		_transition_player.play("fade_in", -1.0, -5.0, true)
	_state = State.READY
	_prep_state = null


func _on_progress_changed(progress) -> void:
	emit_signal("progress_changed", progress)


func _set_as_current( scene: Node ):
	get_tree().set_current_scene( scene )
	assert( get_tree().current_scene == scene )
	emit_signal("scene_set_as_current")


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == FADE_IN:
		emit_signal("faded_in")
		if _state == State.PREPARING:
			_try_switching()
	elif anim_name == FADE_OUT:
		emit_signal("faded_out")


static func _node_from_packed_scene( packed_scene: PackedScene ) -> Node:
	return packed_scene.instance() if packed_scene.can_instance() else null


static func _return_argument( node: Node ) -> Node:
	return node

#-------------------------------------------------------------------------------

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


class SceneLoader extends Reference:
	signal loading_done()
	signal progress_changed(progress)

	var loader_thread := Thread.new()
	var params = null
	var meta = null
	var packed_scene: PackedScene


	func _init(switcher, params_, meta_):
		params = params_
		meta = meta_
# warning-ignore:return_value_discarded
		connect("loading_done", switcher, "_on_preperation_done", [], CONNECT_ONESHOT)
# warning-ignore:return_value_discarded
		connect("progress_changed", switcher, "_on_progress_changed")


	func start_load_from_path(scene_path: String) -> int:
		var error = loader_thread.start(self, "_packed_scene_from_path", scene_path)
		return error


	func start_load_from_path_interactive(scene_path: String) -> int:
		var error = loader_thread.start(self, "_packed_scene_from_path_interactive", scene_path)
		return error


	func _packed_scene_from_path( path: String ) -> void:
		call_deferred("_finalize_load", ResourceLoader.load( path ) )


	func _packed_scene_from_path_interactive( path: String ) -> void:
		var simulated_delay_sec = 0.3
		var ril = ResourceLoader.load_interactive( path )
		assert(ril)
		var total = ril.get_stage_count()

		var res: PackedScene = null

		while true: #iterate until we have a resource
			# Update progress bar, use call deferred, which routes to main thread.
			emit_signal("progress_changed", 100.0 * ril.get_stage() / total)
			#progress.call_deferred("set_value", ril.get_stage())

			# Simulate a delay.
			OS.delay_msec(int(simulated_delay_sec * 1000.0))

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

		call_deferred("_finalize_load", res)


	func _finalize_load( packed_scene_: PackedScene ):
		loader_thread.wait_to_finish()
		packed_scene = packed_scene_
		emit_signal("loading_done")

