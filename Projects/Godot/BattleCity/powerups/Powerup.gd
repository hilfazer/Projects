var m_stage


export var m_duration = 10
var m_blinkTime = m_duration * 0.4
var m_timeLeft = m_duration


func _ready():
	set_process(true)
	
	
func _process(delta):
	m_timeLeft -= delta
	if ( m_timeLeft < m_blinkTime and not get_node("AnimationPlayer").is_playing() ):
		get_node("AnimationPlayer").play("blink")

	if ( m_timeLeft <= 0 ):
		self.queue_free()


func pickup( tank ):
	get_node("PickupAction").execute( m_stage, tank )
	self.queue_free()
