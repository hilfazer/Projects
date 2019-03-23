extends Reference
class_name NodeRAII

var _node_                             setget deleted, getNode


func _init( node : Node ):
	_node_ = node


func _notification(what):
	match what:
		NOTIFICATION_PREDELETE:
			if is_instance_valid(_node_) and not _node_.is_inside_tree():
				_node_.free()


func getNode():
	return _node_


func deleted(_a):
	assert(false)
