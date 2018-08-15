extends Node

export var a = 0
export var b = 1


func serialize():
	return { "a" : a, "b" : b, "SCENE" : filename }


func deserialize( data ):
	a = data["a"]
	b = data["b"]
