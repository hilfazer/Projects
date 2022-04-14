extends Node


func _on_WrongMetaType_pressed():
	SceneSwitcher.switch_scene_to_instance(Node.new(), null, 42)


func _on_NullSceneSource_pressed():
	SceneSwitcher.switch_scene_to_instance(null)


func _on_InvalidScenePath_pressed():
	SceneSwitcher.switch_scene("res:/doesn't exist")


func _on_NodeIsNotAScene_pressed():
	SceneSwitcher.switch_scene_to_instance(Node.new())
