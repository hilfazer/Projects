extends Node2D

#frame offsets
const COLOR_OFFSET = { GOLD = 0, SILVER = 8, GREEN = 200, PURPLE = 208 }

const BULLET_PATH = "res://units/Bullet.tscn"
const SPEED = 40
const FIRING_DELAY = .3
const MOTION = { UP = Vector2(0, -1), DOWN = Vector2(0, 1),
	LEFT = Vector2(-1, 0), RIGHT = Vector2(1, 0), NONE = Vector2(0, 0) }

var cannonEndDistance = 0


func _ready():
	set_process( true )
	set_fixed_process( true )
	cannonEndDistance = abs( self.get_node("CannonEnd").get_pos().y )
	
	var spriteFrame = get_node("Sprite").get_frame()
	if ( spriteFrame >= COLOR_OFFSET.PURPLE ): setColor( COLOR_OFFSET.PURPLE )
	elif ( spriteFrame >= COLOR_OFFSET.GREEN ): setColor( COLOR_OFFSET.GREEN )
	elif ( spriteFrame >= COLOR_OFFSET.SILVER ): setColor( COLOR_OFFSET.SILVER )
	else: setColor( COLOR_OFFSET.GOLD )
	
	self.rotate( 8 )


func _process(delta):
	processMovement( delta )
	processRotation()
	m_firingCooldown -= delta


func _fixed_process(delta):
	processMovement( delta )


var m_motion = MOTION.NONE

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
	
	
var m_colorFrame

func setColor( color ):
	assert ( color in [COLOR_OFFSET.GOLD,COLOR_OFFSET.SILVER,COLOR_OFFSET.GREEN,COLOR_OFFSET.PURPLE] )
	m_colorFrame = color


func processRotation():
	if ( m_motion == MOTION.UP ):
		rotate(8)
	elif ( m_motion == MOTION.DOWN ):
		rotate(2)
	elif ( m_motion == MOTION.LEFT ):
		rotate(4)
	elif ( m_motion == MOTION.RIGHT ):
		rotate(6)


var m_rotation	# 8 == up, 2 == down, 4 == left, 6 == right

func rotate( direction ):
	if (direction == m_rotation):
		return

	m_rotation = direction
	var direction2frame = { 2 : 4, 4 : 2, 6 : 6, 8 : 0 }
	var sprite = get_node("Sprite").set_frame( m_colorFrame + direction2frame[m_rotation] )
	
	if ( m_rotation == 2 ):
		self.get_node("CannonEnd").set_pos( Vector2( 0, cannonEndDistance ) )
	elif ( m_rotation == 4 ):
		self.get_node("CannonEnd").set_pos( Vector2( -cannonEndDistance, 0 ) )
	elif ( m_rotation == 6 ):
		self.get_node("CannonEnd").set_pos( Vector2( cannonEndDistance, 0 ) )
	elif ( m_rotation == 8 ):
		self.get_node("CannonEnd").set_pos( Vector2( 0, -cannonEndDistance ) )


var m_firingCooldown = 0.0

func fireCannon():
	if m_firingCooldown > 0.0:
		return
		
	var bulletScene = load(BULLET_PATH)
	var bullet = bulletScene.instance()
	bullet.rotate(m_rotation)
	self.get_parent().add_child(bullet)
	PS2D.body_add_collision_exception(bullet.get_node("Body2D").get_rid(), get_node("Body2D").get_rid())
	bullet.set_global_pos( self.get_node("CannonEnd").get_global_pos() )
	m_firingCooldown = FIRING_DELAY


		