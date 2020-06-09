extends Control

const SwitchText = "switchScene( %s : filepath )"
const SwitchToText = "switchScene( %s : PackedScene )"
const META_PARAM = "META"

export(String) var nextScene = ""
export(String) var defaultParamText = ""

var paramFromSwitcher

func _init():
	paramFromSwitcher = SceneSwitcher.getParams()
	print( "Scene.gd _init(). params: ", paramFromSwitcher )


func _enter_tree():
	print("Scene.gd _enter_tree(). current: ", get_tree().current_scene, "  self: ", self)


func _ready():
	print("Scene.gd _ready(). current: ", get_tree().current_scene, "  self: ", self)

	$"VBoxButtons/Switch".text = SwitchText % nextScene
	$"VBoxButtons/SwitchTo".text = SwitchToText % nextScene
	$"VBoxParam/LineEditInput".text = defaultParamText

	if paramFromSwitcher != null:
		$"VBoxParam/LineEditReceived".text = paramFromSwitcher
	else:
		$"VBoxParam/LineEditReceived".text = defaultParamText

	if has_meta(META_PARAM):
		if get_meta(META_PARAM) != null:
			$"VBoxParam/LineEditReceivedMeta".text = get_meta(META_PARAM)
		else:
			$"VBoxParam/LineEditReceivedMeta".text = defaultParamText


func switchPath():
	SceneSwitcher.switchScene(nextScene, $"VBoxParam/LineEditInput".text, META_PARAM )


func switchPackedScene():
	var sceneNode = load(nextScene).instance()
	assert( sceneNode.paramFromSwitcher == null )
	var packedScene = PackedScene.new()
	packedScene.pack( sceneNode )
	SceneSwitcher.switchSceneTo( packedScene, $"VBoxParam/LineEditInput".text, META_PARAM )


func switchInstancedScene():
	var metaName = "switchInstancedScene"
	var sceneNode = load(nextScene).instance()
	assert( sceneNode.paramFromSwitcher == null )
# warning-ignore:return_value_discarded
	SceneSwitcher.connect( "sceneSetAsCurrent", sceneNode, "_grabSceneParams" \
		, [], CONNECT_ONESHOT )
# warning-ignore:return_value_discarded
	SceneSwitcher.connect("sceneSetAsCurrent", sceneNode, "_retrieveMeta" \
		, [metaName], CONNECT_ONESHOT )
	SceneSwitcher.switchSceneToInstance( sceneNode, $"VBoxParam/LineEditInput".text, metaName )


func reloadScene():
	if SceneSwitcher.reloadCurrentScene() == ERR_CANT_CREATE:
		print("Couldn't reload a scene")


func switchNull():
	SceneSwitcher.switchSceneTo(null, null)


func _grabSceneParams():
	assert( self == get_tree().current_scene )
	paramFromSwitcher = SceneSwitcher.getParams()


func _retrieveMeta( meta : String ):
	if not has_meta( meta ):
		return

	var param = get_meta( meta )

	if param != null:
		$"VBoxParam/LineEditReceivedMeta".text = param
	else:
		$"VBoxParam/LineEditReceivedMeta".text = defaultParamText


func _retrieveMetaWithScene( _scene, meta : String ):
	_retrieveMeta( meta )
