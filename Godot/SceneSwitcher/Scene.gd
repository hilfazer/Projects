extends Control

export(String) var nextScene = ""


func _on_Button_pressed():
	SceneSwitcher.switchScene(nextScene, $"LineEdit".text)


func _enter_tree():
	print("Scene.gd _enter_tree(). current: ", get_tree().current_scene, "  self: ", self)


func _ready():
	print("Scene.gd _ready(). current: ", get_tree().current_scene, "  self: ", self)
	$"Button".text = "to " + nextScene

	var param = SceneSwitcher.getParams()
	if param != null:
		$"Label".text = param
	else:
		$"Label".text = "..."


func reloadScene():
	get_tree().reload_current_scene()
