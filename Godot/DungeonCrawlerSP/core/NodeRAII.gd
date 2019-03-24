extends Reference
class_name NodeRAII

var _node__                             setget deleted, getNode


func _init( node__ : Node ):
	_node__ = node__


func _notification(what):
	match what:
		NOTIFICATION_PREDELETE:
			if is_instance_valid(_node__) and not _node__.is_inside_tree():
				_node__.free()


func getNode():
	return _node__


func deleted(_a):
	assert(false)
