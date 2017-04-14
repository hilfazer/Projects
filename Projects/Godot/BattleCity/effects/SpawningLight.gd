extends Node2D

var m_glowTimer


func glowForSeconds(seconds):
	m_glowTimer = Timer.new()
	m_glowTimer.set_wait_time( seconds )
	m_glowTimer.set_one_shot(true)
	m_glowTimer.connect( "timeout", self, "expire" )
	get_node("Sprite/AnimationPlayer").play("Glow")
	add_child(m_glowTimer)
	m_glowTimer.start()


func expire():
	var bodies = get_node("Area2D").get_overlapping_bodies()
	for body in bodies:
		if (body.get_parent().has_method("destroy")):
			body.get_parent().destroy()

	self.queue_free()
