extends Reference

func _init( node : Node ):
	m_node_ = node

func _notification(what):
	match what:
		NOTIFICATION_PREDELETE:
			if is_instance_valid(m_node_) and not m_node_.is_inside_tree():
				m_node_.free()

func getNode():
	return m_node_

func deleted(_a):
	assert(false)

var m_node_     setget deleted, getNode
