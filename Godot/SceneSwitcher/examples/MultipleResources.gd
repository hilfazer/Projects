extends Node2D


func _ready():
	var param = SceneSwitcher.get_params(self)
	$"LineEditParams".text = param if param else ""
