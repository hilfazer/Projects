extends Node


const m_duration = 6
var m_durationTimer = Timer.new()


func _ready():
	self.get_node("Sprite/AnimationPlayer").play("play")
	m_durationTimer.set_wait_time(m_duration)
	m_durationTimer.connect("timeout", self, "queue_free")
	add_child(m_durationTimer)
	m_durationTimer.start()


func handleBulletCollision(bullet):
	pass