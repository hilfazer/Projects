extends Control

const SwitchText = "switchScene( %s : filepath )"
const SwitchToText = "switchScene( %s : PackedScene )"

export(String) var nextScene = ""
export(String) var defaultParamText = ""

var m_param


func _init():
	m_param = SceneSwitcher.getParams()
	print( "Scene.gd _init(). params: ", m_param )


func _enter_tree():
	print("Scene.gd _enter_tree(). current: ", get_tree().current_scene, "  self: ", self)


func _ready():
	print("Scene.gd _ready(). current: ", get_tree().current_scene, "  self: ", self)

	$"VBoxButtons/Switch".text = SwitchText % nextScene
	$"VBoxButtons/SwitchTo".text = SwitchToText % nextScene
	$"VBoxParam/LineEditInput".text = defaultParamText

	if m_param != null:
		$"VBoxParam/LineEditReceived".text = m_param
	else:
		$"VBoxParam/LineEditReceived".text = defaultParamText


func switchPath():
	SceneSwitcher.switchScene(nextScene, $"VBoxParam/LineEditInput".text)


func switchPackedScene():
	var sceneNode = load(nextScene).instance()
	assert( sceneNode.m_param == null )
	var packedScene = PackedScene.new()
	packedScene.pack( sceneNode )
	SceneSwitcher.switchSceneTo( packedScene, $"VBoxParam/LineEditInput".text)


func switchInstancedScene():
	var sceneNode = load(nextScene).instance()
	assert( sceneNode.m_param == null )
# warning-ignore:return_value_discarded
	SceneSwitcher.connect( "sceneSetAsCurrent", sceneNode, "_grabSceneParams" \
		, [], CONNECT_ONESHOT )
	SceneSwitcher.switchSceneToInstance( sceneNode, $"VBoxParam/LineEditInput".text )


func reloadScene():
	if SceneSwitcher.reloadCurrentScene() == ERR_CANT_CREATE:
		print("Couldn't reload a scene")


func switchNull():
	SceneSwitcher.switchSceneTo(null, null)


func _grabSceneParams():
	assert( self == get_tree().current_scene )
	m_param = SceneSwitcher.getParams()

