extends Node2D

const BoomAnimation = preload("res://effects/Boom.tscn")

const SpriteY = 96
const BulletsGroup = "Bullets"
const Direction = { 
	UP = Vector2(0, -1),
	DOWN = Vector2(0, 1),
	LEFT = Vector2(-1, 0),
	RIGHT = Vector2(1, 0),
	NONE = Vector2(0, 0)
}
const Direction2SpriteX = { 
	Direction.DOWN : 320+16,
	Direction.LEFT : 320+8,
	Direction.RIGHT : 320+24,
	Direction.UP : 320 
}

export var m_slowSpeed = 150
export var m_normalSpeed = 200
export var m_fastSpeed = 260
var m_impulse = 200            setget setImpulse, deleted
var m_direction = Direction.UP setget deleted, deleted
var m_stage                    setget deleted, deleted
var m_team                     setget setTeam


func deleted(_a):
	assert(false)


func _ready():
	set_process( true )

	var bulletBody = get_node("Body2D")
	bulletBody.apply_impulse( Vector2(0,0), m_direction * m_impulse)
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
	m_direction = direction


func setTeam(team):
	if m_team:
		self.remove_from_group(m_team)

	m_team = team
	self.add_to_group(team)


func setImpulse(impulse):
	m_impulse = impulse