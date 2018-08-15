extends Node


func serialize():
	return { "SCENE" : filename, "CHILDREN" : [] }
	