extends Node2D

const BoomAnimation = preload("res://effects/Boom.tscn")

const SpriteY = 96
const Direction2SpriteX = { 2 : 320+16, 4 : 320+8, 6 : 320+24, 8 : 320 }
const Direction2Motion = { 2 : Vector2(0, 1), 4 : Vector2(-1, 0), 6 : Vector2(1, 0), 8 : Vector2(0, -1)}
const BulletsGroup = "Bullets"

export var m_impulse = 50      
var m_motion = Vector2(0, -1)  setget deleted, deleted
var m_stage                    setget deleted, deleted
var m_team                     setget setTeam


func deleted():
	assert(false)


func _ready():
	set_process( true )

	var bulletBody = get_node("Body2D")
	bulletBody.apply_impulse( Vector2(0,0), m_motion * m_impulse)
	set_fixed_process( true )
	m_stage = weakref( get_parent() )


func _fixed_process(delta):
	var bulletBody = get_node("Body2D")
	self.set_pos( get_pos() + bulletBody.get_pos() )
	bulletBody.set_pos( Vector2(0,0) )

	var size = bulletBody.get_colliding_bodies().size()
	for collider in ( bulletBody.get_colliding_bodies() ):
		if collider.get_parent().has_method("handleBulletCollision"):
			collider.get_parent().handleBulletCollision( self )
		else:
			m_stage.get_ref().processBulletCollision( self, collider )

	if not bulletBody.get_colliding_bodies().empty():
		self.queue_free()
		var boom = BoomAnimation.instance()
		m_stage.get_ref().add_child( boom )
		boom.set_pos( self.get_pos() )
		boom.get_node("Sprite/AnimationPlayer").connect("finished", boom, "queue_free")
		boom.get_node("Sprite/AnimationPlayer").play("Explode")


func rotateToDirection( direction ):
	get_node("Sprite").set_region_rect( Rect2(Direction2SpriteX[direction], SpriteY, 8, 16) )
	m_motion = Direction2Motion[direction]


func setTeam(team):
	m_team = team
	self.add_to_group(team)