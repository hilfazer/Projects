extends Node


onready var m_tank   = get_parent()
const m_duration     = 6
var m_durationTimer  = Timer.new()
var m_tankHandleBulletFunRef


func _ready():
	self.get_node("Sprite/AnimationPlayer").play("play")
	m_durationTimer.set_wait_time(m_duration)
	m_durationTimer.connect("timeout", self, "queue_free")
	add_child(m_durationTimer)
	m_durationTimer.start()
	
	var handleBulletFunRef = FuncRef.new()
	handleBulletFunRef.set_function("handleBulletCollision")
	handleBulletFunRef.set_instance(self)

	m_tankHandleBulletFunRef = m_tank.m_handleBulletFunRef
	m_tank.m_handleBulletFunRef = handleBulletFunRef


func handleBulletCollision(bullet):
	pass
	
	
func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		m_tank.m_handleBulletFunRef = m_tankHandleBulletFunRef