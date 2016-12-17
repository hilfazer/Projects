extends Node2D

const BULLET_PATH = "res://units/Bullet.tscn"
const SPEED = 40
const FIRING_DELAY = .3
const MOTION = { UP = Vector2(0, -1), DOWN = Vector2(0, 1),
	LEFT = Vector2(-1, 0), RIGHT = Vector2(1, 0), NONE = Vector2(0, 0) }

var rotation = 8	# 8 == up, 2 == down, 4 == left, 6 == right
var cannonEndDistance = 0
var m_motion = MOTION.NONE
var m_firingCooldown = 0.0


func _ready():
	set_process( true )
	set_fixed_process( true )
	set_process_input( true )
	cannonEndDistance = abs( self.get_node("CannonEnd").get_pos().y )


func _process(delta):
	processMovement( delta )
	processRotation()
	m_firingCooldown -= delta


func _fixed_process(delta):
	processMovement( delta )

	
func processMovement(delta):
	var body = get_node("Body2D")
	var relative = m_motion.normalized()*SPEED*delta
	var remaining = body.move( relative )
	self.set_pos( get_pos() + body.get_pos() )
	body.set_pos( Vector2(0,0) )


func setMotion( motionVector2d ):
	m_motion = motionVector2d

func getMotion():
	return m_motion

func processRotation():
	if ( m_motion == MOTION.UP ):
		rotate(8)
	elif ( m_motion == MOTION.DOWN ):
		rotate(2)
	elif ( m_motion == MOTION.LEFT ):
		rotate(4)
	elif ( m_motion == MOTION.RIGHT ):
		rotate(6)


func rotate( direction ):
	if (direction == rotation):
		return

	rotation = direction
	var direction2frame = { 2 : 4, 4 : 2, 6 : 6, 8 : 0 }
	var sprite = get_node("Sprite").set_frame( direction2frame[rotation] )
	
	if ( rotation == 2 ):
		self.get_node("CannonEnd").set_pos( Vector2( 0, cannonEndDistance ) )
	elif ( rotation == 4 ):
		self.get_node("CannonEnd").set_pos( Vector2( -cannonEndDistance, 0 ) )
	elif ( rotation == 6 ):
		self.get_node("CannonEnd").set_pos( Vector2( cannonEndDistance, 0 ) )
	elif ( rotation == 8 ):
		self.get_node("CannonEnd").set_pos( Vector2( 0, -cannonEndDistance ) )


func fireCannon():
	if m_firingCooldown > 0.0:
		return
		
	var bulletScene = load(BULLET_PATH)
	var bullet = bulletScene.instance()
	bullet.rotate(rotation)
	self.get_parent().add_child(bullet)
	PS2D.body_add_collision_exception(bullet.get_node("Body2D").get_rid(), get_node("Body2D").get_rid())
	bullet.set_global_pos( self.get_node("CannonEnd").get_global_pos() )
	m_firingCooldown = FIRING_DELAY


		
		