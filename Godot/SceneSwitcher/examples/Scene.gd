extends Control

const SwitchText = "switch_scene( %s : filepath )"
const SwitchToText = "switch_scene( %s : PackedScene )"
const META_PARAM = "META"

export(String) var nextScene = ""
export(String) var defaultParamText = ""
export(String) var interactive_scene: String

var paramFromSwitcher


func _enter_tree():
	print("Scene.gd _enter_tree(). current: ", get_tree().current_scene, "  self: ", self)
	paramFromSwitcher = SceneSwitcher.get_params(self)


func _ready():
	print("Scene.gd _ready(). current: ", get_tree().current_scene, "  self: ", self)

	$"VBoxButtons/Switch".text = SwitchText % nextScene
	$"VBoxButtons/SwitchTo".text = SwitchToText % nextScene
	$"VBoxParam/LineEditInput".text = defaultParamText
	$"VBoxParam/LineEditReceived".text = paramFromSwitcher if paramFromSwitcher else defaultParamText

	if has_meta(META_PARAM):
		var param = get_meta(META_PARAM)
		$"VBoxParam/LineEditReceivedMeta".text = param if param else defaultParamText


func switchPath():
	SceneSwitcher.switch_scene(nextScene, $"VBoxParam/LineEditInput".text, META_PARAM )


func switchPackedScene():
	var sceneNode = load(nextScene).instance()
	assert( sceneNode.paramFromSwitcher == null )
	var packedScene = PackedScene.new()
	packedScene.pack( sceneNode )
	SceneSwitcher.switch_scene_to( packedScene, $"VBoxParam/LineEditInput".text, META_PARAM )


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
	SceneSwitcher.switch_scene_to_instance( sceneNode, $"VBoxParam/LineEditInput".text, metaName )


func reloadScene():
	if SceneSwitcher.reload_current_scene() == ERR_CANT_CREATE:
		print("Couldn't reload a scene")


func switch_interactive():
	SceneSwitcher.switch_scene_interactive(interactive_scene, $"VBoxParam/LineEditInput".text )


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


