extends Node

var f := 0.0
var s := ""


func serialize():
	return { 'f' : f, 's' : s }


func deserialize( data ):
	f = data['f']
	s = data['s']
