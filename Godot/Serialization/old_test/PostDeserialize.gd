extends Node2D

var i := 0
var ii : int


func serialize():
	return i


func deserialize( data ):
	i = data


func post_deserialize():
	ii = i
