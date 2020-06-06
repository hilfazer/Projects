extends Node

var s := ""


func serialize():
	return s


func deserialize( data ):
	s = data
