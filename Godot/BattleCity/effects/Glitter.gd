extends Node2D

var m_glitterTimer = Timer.new() setget deleted, deleted

signal finished


func deleted(_a):
	assert(false)


func _ready():
	add_child(m_glitterTimer)


func glitterForSeconds(seconds):
	var animationPlayer = get_node("Sprite/AnimationPlayer")
	m_glitterTimer.set_wait_time( seconds )
	if animationPlayer.is_playing():
		m_glitterTimer.start()
		return

	m_glitterTimer.set_one_shot(true)
	m_glitterTimer.connect( "timeout", animationPlayer, "stop" )
	m_glitterTimer.connect( "timeout", self, "stopGlittering" )
	animationPlayer.play("Glitter")
	m_glitterTimer.start()


func stopGlittering():
	get_node("Sprite/AnimationPlayer").stop()
	emit_signal("finished")
