extends Node2D

const BulletScn = preload("res://units/Bullet.tscn")
const BoomBigScn = preload("res://effects/BoomBig.tscn")

#frame offsets
const ColorOffset = { GOLD = 0, SILVER = 8, GREEN = 200, PURPLE = 208 }
const TypeOffset = { MK1 = 0, MK2 = 25, MK3 = 50, MK4 = 75, MK5 = 100, MK6 = 125, MK7 = 150, MK8 = 175 }
const DirectionOffset = { UP = 0, LEFT = 2, DOWN = 4, RIGHT = 6 }
const ShootingDelay = .3
const Motion = { UP = Vector2(0, -1), DOWN = Vector2(0, 1),
	LEFT = Vector2(-1, 0), RIGHT = Vector2(1, 0), NONE = Vector2(0, 0) }
const Direction2Frame = {
	2 : DirectionOffset.DOWN,
	4 : DirectionOffset.LEFT,
	6 : DirectionOffset.RIGHT,
	8 : DirectionOffset.UP
}

export var m_speed = 40            
var m_stage                        setget deleted
var m_typeFrame = TypeOffset.MK1   setget deleted
var m_motion = Motion.NONE         setget setMotion
var m_colorFrame                   setget deleted, deleted
var m_rotation = 8                 setget deleted, deleted
var m_frameToAnimationName = {}    setget deleted, deleted
var m_currrentAnimationName = ""   setget deleted, deleted
var m_firingCooldown = 0.0         setget deleted, deleted
var m_cannonEndDistance = 0        setget deleted, deleted
var m_team = null                  setget setTeam


func deleted():
	assert(false)


func _ready():
	set_process( true )
	set_fixed_process( true )
	m_cannonEndDistance = abs( self.get_node("CannonEnd").get_pos().y )
	
	var spriteFrame = get_node("Sprite").get_frame()
	if ( spriteFrame >= ColorOffset.PURPLE ):    setColor( ColorOffset.PURPLE )
	elif ( spriteFrame >= ColorOffset.GREEN ):   setColor( ColorOffset.GREEN )
	elif ( spriteFrame >= ColorOffset.SILVER ):  setColor( ColorOffset.SILVER )
	else:                                        setColor( ColorOffset.GOLD )

	self.rotateToDirection( 8 )
	m_stage = weakref( get_parent() )
	

func _process(delta):
	processMovement( delta )
	processRotation()
	processAnimation()
	m_firingCooldown -= delta


func _fixed_process(delta):
	processMovement( delta )


func setTankType( type ):
	m_typeFrame = type
	addAnimations( m_colorFrame, m_typeFrame )


func processMovement( delta ):
	var body = get_node("Body2D")
	var relative = m_motion.normalized()*m_speed*delta
	body.move( relative )
	
	self.set_pos( get_pos() + body.get_pos() ) # move root node of a tank to where physics body is
	body.set_pos( Vector2(0,0) ) # previous line has moved body as well so we need to revert that


func setMotion( motionVector2d ):
	m_motion = motionVector2d


func setColor( color ):
	assert ( color in [ColorOffset.GOLD,ColorOffset.SILVER,ColorOffset.GREEN,ColorOffset.PURPLE] )
	m_colorFrame = color
	addAnimations( m_colorFrame, m_typeFrame )


func addAnimations(colorFrame, tankTypeFrame):
	for directionFrame in DirectionOffset:
		var firstFrame = m_colorFrame + m_typeFrame + DirectionOffset[directionFrame]
		if ( firstFrame in m_frameToAnimationName ):
			continue

		var animationToAdd = get_node("Sprite/AnimationPlayer").get_animation("Drive").duplicate()
		var trackIdx = animationToAdd.find_track(".:frame")
		for keyIdx in range(0, animationToAdd.track_get_key_count( trackIdx ) ):
			animationToAdd.track_set_key_value( \
				trackIdx, keyIdx, firstFrame + keyIdx)
		get_node("Sprite/AnimationPlayer").add_animation("Drive"+str(firstFrame), animationToAdd)
		m_frameToAnimationName[firstFrame] = "Drive"+str(firstFrame)


func processRotation():
	if ( m_motion == Motion.UP ):
		rotateToDirection(8)
	elif ( m_motion == Motion.DOWN ):
		rotateToDirection(2)
	elif ( m_motion == Motion.LEFT ):
		rotateToDirection(4)
	elif ( m_motion == Motion.RIGHT ):
		rotateToDirection(6)


func rotateToDirection( direction ):
	if (direction == m_rotation):
		return

	m_rotation = direction
	var sprite = get_node("Sprite").set_frame( m_colorFrame + Direction2Frame[m_rotation] )
	m_currrentAnimationName = m_frameToAnimationName[get_node("Sprite").get_frame()]

	if ( m_rotation == 2 ):
		self.get_node("CannonEnd").set_pos( Vector2( 0, m_cannonEndDistance ) )
	elif ( m_rotation == 4 ):
		self.get_node("CannonEnd").set_pos( Vector2( -m_cannonEndDistance, 0 ) )
	elif ( m_rotation == 6 ):
		self.get_node("CannonEnd").set_pos( Vector2( m_cannonEndDistance, 0 ) )
	elif ( m_rotation == 8 ):
		self.get_node("CannonEnd").set_pos( Vector2( 0, -m_cannonEndDistance ) )


func processAnimation():
	if ( m_motion == Motion.NONE):
		get_node("Sprite/AnimationPlayer").stop()
	elif ( get_node("Sprite/AnimationPlayer").get_current_animation() != m_currrentAnimationName ):
		get_node("Sprite/AnimationPlayer").play( m_currrentAnimationName )


func fireCannon():
	if m_firingCooldown > 0.0:
		return

	var bullet = BulletScn.instance()
	bullet.rotateToDirection(m_rotation)
	PS2D.body_add_collision_exception(bullet.get_node("Body2D").get_rid(), self.get_node("Body2D").get_rid())

	for existingBullet in get_tree().get_nodes_in_group( bullet.BulletsGroup ):
		if ( existingBullet.m_team == self.m_team ):
			PS2D.body_add_collision_exception( bullet.get_node("Body2D").get_rid(), existingBullet.get_node("Body2D").get_rid() )

	bullet.add_to_group( bullet.BulletsGroup )
	assert( m_team != null )
	bullet.setTeam(m_team)

	m_stage.get_ref().add_child(bullet)
	bullet.set_global_pos( self.get_node("CannonEnd").get_global_pos() )

	m_firingCooldown = ShootingDelay


func setTeam(team):
	m_team = team
	self.add_to_group(team)


func destroy():
	self.queue_free()
	var boom = BoomBigScn.instance()
	m_stage.get_ref().add_child( boom )
	boom.set_pos( self.get_pos() )
	boom.get_node("Sprite/AnimationPlayer").connect("finished", boom, "queue_free")
	boom.get_node("Sprite/AnimationPlayer").play("Explode")
	
	