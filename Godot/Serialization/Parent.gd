extends Node

export var p = 0




func serialize():
	return {
		"SCENE" : filename,
		"p" : p,
	}


func postDeserialize():
	print("Parent has %d children" % get_child_count())
	
	