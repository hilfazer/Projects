extends Node


func _init():
	SceneSwitcher.connect("sceneInstanced", self, "onInstanced")
	SceneSwitcher.connect("sceneSetAsCurrent", self, "onCurrentChanged")


func onInstanced( scene ):
	var sceneFilename = scene.filename if scene.filename else "without filename"
	print( "Scene %s instanced" % sceneFilename )
	scene.connect("tree_entered", self, "onEntered", [scene], CONNECT_ONESHOT )


func onEntered( scene ):
	var sceneFilename = scene.filename if scene.filename else "without filename"
	print( "Scene %s has entered the tree" % sceneFilename )


func onCurrentChanged():
	var sceneFilename = get_tree().current_scene.filename \
		if get_tree().current_scene.filename else "without filename"
	print( "Scene %s is a current scene" % sceneFilename )
