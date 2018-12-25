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
	$"VBoxParam/LineEdit".text = defaultParamText

	if m_param != null:
		$"VBoxParam/Label".text = m_param
	else:
		$"VBoxParam/Label".text = defaultParamText


func switchPath():
	SceneSwitcher.switchScene(nextScene, $"VBoxParam/LineEdit".text)
	

func switchPackedScene():
	var sceneNode = load(nextScene).instance()
	assert( sceneNode.m_param == null )
	var packedScene = PackedScene.new()
	packedScene.pack( sceneNode )
	SceneSwitcher.switchSceneTo( packedScene, $"VBoxParam/LineEdit".text)


func reloadScene():
	if SceneSwitcher.reloadCurrentScene() == ERR_CANT_CREATE:
		print("Couldn't reload a scene")


func switchNull():
	SceneSwitcher.switchScene(null, null)
	
	