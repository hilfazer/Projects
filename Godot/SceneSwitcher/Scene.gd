extends Control

const SwitchText = "switchScene( %s : filepath )"
const SwitchToText = "switchScene( %s : PackedScene )"

export(String) var nextScene = ""


func _enter_tree():
	print("Scene.gd _enter_tree(). current: ", get_tree().current_scene, "  self: ", self)


func _ready():
	print("Scene.gd _ready(). current: ", get_tree().current_scene, "  self: ", self)

	$"VBoxButtons/Switch".text = SwitchText % nextScene
	$"VBoxButtons/SwitchTo".text = SwitchToText % nextScene

	var param = SceneSwitcher.getParams()
	if param != null:
		$"VBoxParam/Label".text = param
	else:
		$"VBoxParam/Label".text = "..."


func switchPath():
	SceneSwitcher.switchScene(nextScene, $"VBoxParam/LineEdit".text)
	

func switchPackedScene():
	var sceneNode = load(nextScene).instance()
	var packedScene = PackedScene.new()
	packedScene.pack( sceneNode )
	SceneSwitcher.switchSceneTo( packedScene, $"VBoxParam/LineEdit".text)


func reloadScene():
	get_tree().reload_current_scene()


func switchNull():
	SceneSwitcher.switchScene(null, null)
	
	