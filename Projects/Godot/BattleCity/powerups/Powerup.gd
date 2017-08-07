var m_stage


const Duration = 10
const BlinkTime = 4
var m_timeLeft = Duration


func _ready():
	set_process(true)
	
	
func _process(delta):
	m_timeLeft -= delta
	if ( m_timeLeft < BlinkTime and not get_node("AnimationPlayer").is_playing() ):
		get_node("AnimationPlayer").play("blink")
	
	if ( m_timeLeft <= 0 ):
		self.queue_free()


func pickup( tank ):
	get_node("PickupAction").execute( m_stage, tank )
	self.queue_free()
