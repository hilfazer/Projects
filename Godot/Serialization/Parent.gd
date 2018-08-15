extends Node

export var p = 0


func serialize():
	return {
		"SCENE" : filename,
		"p" : p,
		"CHILDREN" : { $Child.name : $Child.serialize() }
	}
