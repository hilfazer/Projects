extends Node


const Duration       = 6
onready var m_tank   = get_parent()  setget deleted
var m_durationTimer  = Timer.new()   setget deleted
var m_tankHandleBulletFunRef         setget deleted


func deleted(_a):
	assert(false)


func _ready():
	self.get_node("Sprite/AnimationPlayer").play("play")
	m_durationTimer.set_wait_time(Duration)
	m_durationTimer.connect("timeout", self, "queue_free")
	add_child(m_durationTimer)
	m_durationTimer.start()
	
	var handleBulletFunRef = FuncRef.new()
	handleBulletFunRef.set_function("handleBulletCollision")
	handleBulletFunRef.set_instance(self)

	m_tankHandleBulletFunRef = m_tank.m_handleBulletFunRef
	m_tank.m_handleBulletFunRef = handleBulletFunRef


func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		m_tank.m_handleBulletFunRef = m_tankHandleBulletFunRef


func handleBulletCollision(bullet):
	pass
	
	
func resetDuration():
	m_durationTimer.set_wait_time(Duration)
	m_durationTimer.start()