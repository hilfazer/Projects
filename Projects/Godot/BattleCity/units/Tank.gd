extends Node2D

#frame offsets
const COLOR_OFFSET = { GOLD = 0, SILVER = 8, GREEN = 200, PURPLE = 208 }
const TYPE_OFFSET = { MK1 = 0, MK2 = 25, MK3 = 50, MK4 = 75, MK5 = 100, MK6 = 125, MK7 = 150, MK8 = 175 }
const DIRECTION_OFFSET = { UP = 0, LEFT = 2, DOWN = 4, RIGHT = 6 }
const BULLET_PATH = "res://units/Bullet.tscn"
const SPEED = 40
const FIRING_DELAY = .3
const MOTION = { UP = Vector2(0, -1), DOWN = Vector2(0, 1),
	LEFT = Vector2(-1, 0), RIGHT = Vector2(1, 0), NONE = Vector2(0, 0) }
const PLAYERS_GROUP = "Players"
const ENEMIES_GROUP = "Enemies"

var cannonEndDistance = 0
var stage


func _ready():
	set_process( true )
	set_fixed_process( true )
	cannonEndDistance = abs( self.get_node("CannonEnd").get_pos().y )
	
	var spriteFrame = get_node("Sprite").get_frame()
	if ( spriteFrame >= COLOR_OFFSET.PURPLE ): setColor( COLOR_OFFSET.PURPLE )
	elif ( spriteFrame >= COLOR_OFFSET.GREEN ): setColor( COLOR_OFFSET.GREEN )
	elif ( spriteFrame >= COLOR_OFFSET.SILVER ): setColor( COLOR_OFFSET.SILVER )
	else: setColor( COLOR_OFFSET.GOLD )
	
	self.rotateToDirection( 8 )
	stage = get_parent()
	

func _process(delta):
	processMovement( delta )
	processRotation()
	processAnimation()
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
	
	var animation = get_node("Sprite/AnimationPlayer").get_animation("DriveUp")
	var trackIdx = animation.find_track(".:frame")
	#var 
	
	for keyIdx in range(0, animation.track_get_key_count( trackIdx ) ):
		animation.track_set_key_value(trackIdx, keyIdx, 9)
	


func processRotation():
	if ( m_motion == MOTION.UP ):
		rotateToDirection(8)
	elif ( m_motion == MOTION.DOWN ):
		rotateToDirection(2)
	elif ( m_motion == MOTION.LEFT ):
		rotateToDirection(4)
	elif ( m_motion == MOTION.RIGHT ):
		rotateToDirection(6)


var m_rotation	# 8 == up, 2 == down, 4 == left, 6 == right

func rotateToDirection( direction ):
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


func processAnimation():
	if ( m_motion == MOTION.NONE):
		get_node("Sprite/AnimationPlayer").stop()
	elif ( get_node("Sprite/AnimationPlayer").is_playing() == false ):
		get_node("Sprite/AnimationPlayer").play("DriveUp")
		

var m_firingCooldown = 0.0

func fireCannon():
	if m_firingCooldown > 0.0:
		return

	var bulletScene = load(BULLET_PATH)
	var bullet = bulletScene.instance()
	bullet.rotateToDirection(m_rotation)
	PS2D.body_add_collision_exception(bullet.get_node("Body2D").get_rid(), self.get_node("Body2D").get_rid())

	for existingBullet in get_tree().get_nodes_in_group( bullet.BULLETS_GROUP ):
		if ( existingBullet.is_in_group( PLAYERS_GROUP ) and self.is_in_group(PLAYERS_GROUP) ):
			PS2D.body_add_collision_exception( bullet.get_node("Body2D").get_rid(), existingBullet.get_node("Body2D").get_rid() )
		elif ( existingBullet.is_in_group( ENEMIES_GROUP ) and self.is_in_group(ENEMIES_GROUP) ):
			PS2D.body_add_collision_exception( bullet.get_node("Body2D").get_rid(), existingBullet.get_node("Body2D").get_rid() )

	bullet.add_to_group( bullet.BULLETS_GROUP )
	if ( self.is_in_group( PLAYERS_GROUP )):
		bullet.add_to_group( PLAYERS_GROUP )
	elif ( self.is_in_group( ENEMIES_GROUP )):
		bullet.add_to_group( ENEMIES_GROUP )

	stage.add_child(bullet)
	bullet.set_global_pos( self.get_node("CannonEnd").get_global_pos() )

	m_firingCooldown = FIRING_DELAY
	
	