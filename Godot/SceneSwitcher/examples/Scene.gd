extends Control

const SWITCH_TEXT = "switch_scene( %s : filepath )"
const SWITCH_TO_TEXT = "switch_scene( %s : PackedScene )"
const SWITCH_INTERACTIVE_TEXT = "switch_interactive( %s : filepath )"
const PARAM_META_KEY = "META"

export(String) var nextScene := ""
export(String) var defaultParamText := ""
export(String) var interactive_scene := ""

var paramFromSwitcher


func _enter_tree():
	print("Scene.gd _enter_tree(). current: ", get_tree().current_scene, "  self: ", self)
	paramFromSwitcher = SceneSwitcher.get_params(self)


func _ready():
	print("Scene.gd _ready(). current: ", get_tree().current_scene, "  self: ", self)

	$"VBoxButtons/Switch".text = SWITCH_TEXT % nextScene
	$"VBoxButtons/SwitchTo".text = SWITCH_TO_TEXT % nextScene
	$"VBoxButtons/SwitchInteractive".text = SWITCH_INTERACTIVE_TEXT % interactive_scene
	$"VBoxParam/LineEditInput".text = defaultParamText
	$"VBoxParam/LineEditReceived".text = paramFromSwitcher if paramFromSwitcher else defaultParamText

	if has_meta(PARAM_META_KEY):
		var param = get_meta(PARAM_META_KEY)
		$"VBoxParam/LineEditReceivedMeta".text = param if param else defaultParamText


func switchPath():
# warning-ignore:return_value_discarded
	SceneSwitcher.switch_scene(nextScene, $"VBoxParam/LineEditInput".text, PARAM_META_KEY )


func switchPackedScene():
	var sceneNode = load(nextScene).instance()
	assert( sceneNode.paramFromSwitcher == null )
	var packedScene = PackedScene.new()
	packedScene.pack( sceneNode )
	sceneNode.free()
	var error = SceneSwitcher.switch_scene_to( packedScene, $"VBoxParam/LineEditInput".text, PARAM_META_KEY )
	assert(error == OK)


func switchInstancedScene():
	var metaName = "switchInstancedScene"
	var sceneNode = load(nextScene).instance()
	assert( sceneNode.paramFromSwitcher == null )
# warning-ignore:return_value_discarded
	SceneSwitcher.connect( "scene_set_as_current", sceneNode, "_grabSceneParams" \
		, [], CONNECT_ONESHOT )
# warning-ignore:return_value_discarded
	SceneSwitcher.connect("scene_set_as_current", sceneNode, "_retrieveMeta" \
		, [metaName], CONNECT_ONESHOT )

	var error = SceneSwitcher.switch_scene_to_instance( sceneNode, $"VBoxParam/LineEditInput".text, metaName )
	assert(error == OK)


func reloadScene():
	if SceneSwitcher.reload_current_scene() == ERR_CANT_CREATE:
		print("Couldn't reload a scene")


func switch_interactive():
	var error = SceneSwitcher.switch_scene_interactive(interactive_scene, $"VBoxParam/LineEditInput".text )
	assert(error == OK)


func clear_scene():
	SceneSwitcher.clear_scene()


func _grabSceneParams():
	assert( self == get_tree().current_scene )
	paramFromSwitcher = SceneSwitcher.get_params(self)


func _retrieveMeta( meta : String ):
	var param = get_meta( meta ) if has_meta( meta ) else null
	$"VBoxParam/LineEditReceivedMeta".text = param if param else defaultParamText


func _retrieveMetaWithScene( _scene, meta : String ):
	_retrieveMeta( meta )


