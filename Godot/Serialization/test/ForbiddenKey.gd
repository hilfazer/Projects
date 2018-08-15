extends Node2D


var a = 0
var b = 1


func serialize():
	return { "a" : a, "b" : b, "SCENE" : filename }