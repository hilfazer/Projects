extends Node


var ii : int = 12
var ff : float = 3.6


func serialize():
	return [ii, ff]


func deserialize( data ):
	ii = data.ii
	ff = data.ff
