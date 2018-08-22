extends Node

export var a = 0
export var b = 1


func serialize():
	return { '0' : a, '1' : b, "SCENE" : filename }


func deserialize( data ):
	a = data['0']
	b = data['1']
