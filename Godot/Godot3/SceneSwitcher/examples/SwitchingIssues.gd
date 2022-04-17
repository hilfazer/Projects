extends Node

const Scene1Scn = preload("res://examples/MultipleResources.tscn")


func _on_WrongMetaType_pressed():
	var scene = Scene1Scn.instance()
	SceneSwitcher.switch_scene_to_instance(scene, null, 42)
	scene.free()


func _on_NullSceneSource_pressed():
	SceneSwitcher.switch_scene_to_instance(null)


func _on_InvalidScenePath_pressed():
	SceneSwitcher.switch_scene("res:/doesn't exist", 1337, "key")


func _on_NodeIsNotAScene_pressed():
	SceneSwitcher.switch_scene_to_instance(Node.new())
