extends Reference

const UnitBaseGd                 = preload("res://core/UnitBase.gd")

var m_owner : int = 0                  setget deleted
var m_unitNode_ : UnitBaseGd           setget deleted


func deleted(_a):
	assert(false)


func _init( unit_ : UnitBaseGd, networkOwner : int ):
	setUnitNode( unit_ )
	setOwner( networkOwner )


func _notification(what):
	match what:
		NOTIFICATION_PREDELETE:
			if not m_unitNode_.is_inside_tree():
				m_unitNode_.free()
			elif self:
				setOwner( Network.ServerId )


func setOwner( networkOwner : int ):
	assert( m_unitNode_.m_unitOwner * networkOwner == 0 )
	m_owner = networkOwner
	m_unitNode_.m_unitOwner = networkOwner
	m_unitNode_.setNameLabel( str(m_owner) )


func setUnitNode( unit_ : UnitBaseGd ):
	m_unitNode_ = unit_
	m_unitNode_.setNameLabel( str(m_owner) )


