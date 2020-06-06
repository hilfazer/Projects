extends Node

var f := 0.0


func serialize():
	return f


func deserialize( data ):
	f = data
