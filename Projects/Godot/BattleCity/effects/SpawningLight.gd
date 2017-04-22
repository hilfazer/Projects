extends Node2D

var m_glitterTimer


func glitterForSeconds(seconds):
	m_glitterTimer = Timer.new()
	m_glitterTimer.set_wait_time( seconds )
	m_glitterTimer.set_one_shot(true)
	m_glitterTimer.connect( "timeout", self, "expire" )
	get_node("Sprite/AnimationPlayer").play("Glitter")
	add_child(m_glitterTimer)
	m_glitterTimer.start()


func expire():
	var bodies = get_node("Area2D").get_overlapping_bodies()
	for body in bodies:
		if (body.get_parent().has_method("destroy")):
			body.get_parent().destroy()

	self.queue_free()
