extends Control

export(String) var nextScene = ""


func _on_Button_pressed():
	SceneSwitcher.switchScene(nextScene, $"LineEdit".text)


func _ready():
	$"Button".text = "to " + nextScene

	var param = SceneSwitcher.getParams()
	if param != null:
		$"Label".text = param


func reloadScene():
	get_tree().reload_current_scene()
