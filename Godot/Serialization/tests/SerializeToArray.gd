extends Node

var f := 0.0
var i := 0


func serialize():
	return [f, i]


func deserialize( data ):
	f = data[0]
	i = data[1]
