extends Node


func _init():
# warning-ignore:return_value_discarded
	SceneSwitcher.connect("scene_instanced", self, "onInstanced")
# warning-ignore:return_value_discarded
	SceneSwitcher.connect("scene_set_as_current", self, "onCurrentChanged")


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
