extends Node


func _init():
	SceneSwitcher.connect("sceneInstanced", self, "onInstanced")
	SceneSwitcher.connect("sceneSetAsCurrent", self, "onCurrentChanged")


func onInstanced( scene ):
	print( "Scene %s instanced" % scene.filename )
	scene.connect("tree_entered", self, "onEntered", [scene], CONNECT_ONESHOT )


func onEntered( scene ):
	print( "Scene %s entering tree" % scene.filename )


func onCurrentChanged():
	print( "Scene %s is a current scene" % get_tree().current_scene.filename )
