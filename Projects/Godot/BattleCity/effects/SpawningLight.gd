extends Node2D

var m_glowTimer


func glowForSeconds(seconds):
	m_glowTimer = Timer.new()
	m_glowTimer.set_wait_time( seconds )
	m_glowTimer.set_one_shot(true)
	m_glowTimer.connect( "timeout", self, "tryToDie" )
	get_node("Sprite/AnimationPlayer").play("Glow")
	add_child(m_glowTimer)
	m_glowTimer.start()


func tryToDie():
	self.queue_free()