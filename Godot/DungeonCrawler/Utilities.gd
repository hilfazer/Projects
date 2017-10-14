extends Node


signal sendVariable(name, value)


func setFreeing( node ):
	if node:
		node.set_name(node.get_name() + "_freeing")
		node.queue_free()
		node = null
	