extends Reference

const UnitBaseGd                 = preload("res://core/UnitBase.gd")

var m_unitNode_ : UnitBaseGd           setget deleted


func deleted(_a):
	assert(false)


func _init( unit_ : UnitBaseGd ):
	setUnitNode( unit_ )


func _notification(what):
	match what:
		NOTIFICATION_PREDELETE:
			if not m_unitNode_.is_inside_tree():
				m_unitNode_.free()


func setUnitNode( unit_ : UnitBaseGd ):
	m_unitNode_ = unit_


