# this class will prevent memory leak by freeing Node if it's outside of SceneTree
# call release() if you want to handle memory yourself
extends Reference


var node : Node


func _init( n : Node = null ):
	node = n


func release() -> Node:
	var toReturn = node
	node = null
	return toReturn


func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		if is_instance_valid( node ) \
			and not node.is_inside_tree() \
			and not node.get_parent():
			node.free()
