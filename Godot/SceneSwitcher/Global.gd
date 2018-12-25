extends Node


func _init():
	SceneSwitcher.connect("sceneInstanced", self, "onInstanced")
	SceneSwitcher.connect("sceneSetAsCurrent", self, "onCurrentChanged")


func onInstanced( scene ):
	var sceneFilename = scene.filename if scene.filename else "no filename"
	print( "Scene %s [%s] instanced" % [scene, sceneFilename] )
	scene.connect("tree_entered", self, "onEntered", [scene], CONNECT_ONESHOT )


func onEntered( scene ):
	var sceneFilename = scene.filename if scene.filename else "no filename"
	print( "Scene %s [%s] has entered the tree" % [scene, sceneFilename] )


func onCurrentChanged():
	var sceneFilename = get_tree().current_scene.filename \
		if get_tree().current_scene.filename else "no filename"
	print( "Scene %s [%s] is a current scene" % [get_tree().current_scene, sceneFilename] )
