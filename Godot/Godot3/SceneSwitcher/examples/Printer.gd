extends Node


onready var _play_animations_button: CheckButton = $"HBoxContainer/CheckButtonPlay"
onready var _progress_bar: ProgressBar = $"HBoxContainer/ProgressBar"


func _ready():
# warning-ignore:return_value_discarded
	SceneSwitcher.connect("scene_instanced", self, "onInstanced")
# warning-ignore:return_value_discarded
	SceneSwitcher.connect("scene_set_as_current", self, "onCurrentChanged")
# warning-ignore:return_value_discarded
	SceneSwitcher.connect("progress_changed", _progress_bar, "set_value")
# warning-ignore:return_value_discarded
	SceneSwitcher.connect("faded_in", self, "on_faded_in")
# warning-ignore:return_value_discarded
	SceneSwitcher.connect("faded_out", self, "on_faded_out")

	SceneSwitcher.play_animations = _play_animations_button.pressed


func onInstanced( scene ):
	var sceneFilename = scene.filename if scene.filename else "no filename"
	print( "Scene %s [%s] instanced" % [scene, sceneFilename] )
	scene.connect("tree_entered", self, "onEntered", [scene], CONNECT_ONESHOT )
# warning-ignore:return_value_discarded
	scene.connect("ready", self, "onReady", [scene], CONNECT_ONESHOT )


func onEntered( scene ):
	var sceneFilename = scene.filename if scene.filename else "no filename"
	print( "Scene %s [%s] has entered the tree" % [scene, sceneFilename] )


func onCurrentChanged():
	var sceneFilename = get_tree().current_scene.filename \
		if get_tree().current_scene.filename else "no filename"
	print( "Scene %s [%s] is a current scene" % [get_tree().current_scene, sceneFilename] )


func onReady( scene ):
	var sceneFilename = scene.filename if scene.filename else "no filename"
	print( "Scene %s [%s] is ready" % [scene, sceneFilename] )


func on_faded_in():
	print("Faded in")


func on_faded_out():
	print("Faded out")
	print_stray_nodes()


func _on_ButtonPrintStray_pressed():
	print_stray_nodes()


func _on_CheckButtonPlay_toggled(button_pressed):
	SceneSwitcher.play_animations = button_pressed
