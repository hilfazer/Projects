extends Reference

const UnitGd                 = preload("res://core/Unit.gd")

var m_owner : int = 0                  setget deleted
var m_unitNode_ : UnitGd               setget deleted


func deleted(_a):
	assert(false)


func _init( unit_ : UnitGd, owner : int ):
	setUnitNode( unit_ )
	setOwner( owner )


func _notification(what):
	match what:
		NOTIFICATION_PREDELETE:
			if not m_unitNode_.is_inside_tree():
				m_unitNode_.free()


func setOwner( id : int ):
	m_owner = id


func setUnitNode( unit_ : UnitGd ):
	m_unitNode_ = unit_


