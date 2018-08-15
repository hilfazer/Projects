extends Node

export var p = 0




func serialize():
	return {p : p}


func deserialize( data ):
	p = data[p]


func postDeserialize():
	print("Parent has %d children" % get_child_count())

