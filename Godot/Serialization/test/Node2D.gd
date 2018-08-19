extends Node2D

export var a = 2
export var b = "text"

func serialize():
	return {0 : a, 1 : b}
	
	
func deserialize( dict ):
	a = dict[0]
	b = dict[1]
