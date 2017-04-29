extends Node2D

var m_glitterTimer

signal finished

func glitterForSeconds(seconds):
	var animationPlayer = get_node("Sprite/AnimationPlayer")
	m_glitterTimer = Timer.new()
	m_glitterTimer.set_wait_time( seconds )
	m_glitterTimer.set_one_shot(true)
	m_glitterTimer.connect( "timeout", animationPlayer, "stop" )
	m_glitterTimer.connect( "timeout", self, "stopGlittering" )
	animationPlayer.play("Glitter")
	add_child(m_glitterTimer)
	m_glitterTimer.start()


func stopGlittering():
	emit_signal("finished")
