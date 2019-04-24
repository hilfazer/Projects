extends Node2D

var s := ""


func serialize():
	return s


func deserialize( data ):
	s = data
