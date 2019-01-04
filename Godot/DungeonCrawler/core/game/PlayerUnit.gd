extends Reference

const UnitBaseGd                 = preload("res://core/UnitBase.gd")

var m_owner : int = 0                  setget deleted
var m_unitNode_ : UnitBaseGd               setget deleted


func deleted(_a):
	assert(false)


func _init( unit_ : UnitBaseGd, owner : int ):
	setUnitNode( unit_ )
	setOwner( owner )


func _notification(what):
	match what:
		NOTIFICATION_PREDELETE:
			if not m_unitNode_.is_inside_tree():
				m_unitNode_.free()


func setOwner( id : int ):
	m_owner = id


func setUnitNode( unit_ : UnitBaseGd ):
	m_unitNode_ = unit_


