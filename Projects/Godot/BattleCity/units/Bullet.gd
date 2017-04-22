extends Node2D

const BoomAnimation = preload("res://effects/Boom.tscn")

const SPRITE_Y = 96
const DIRECTION2SPRITE_X = { 2 : 320+16, 4 : 320+8, 6 : 320+24, 8 : 320 }
const DIRECTION2MOTION = { 2 : Vector2(0, 1), 4 : Vector2(-1, 0), 6 : Vector2(1, 0), 8 : Vector2(0, -1)}
const BULLETS_GROUP = "Bullets"

export var m_impulse = 50
var m_motion = Vector2(0, -1)
var m_stage


func _ready():
	set_process( true )
	
	var bulletBody = get_node("Body2D")
	bulletBody.apply_impulse( Vector2(0,0), m_motion.normalized() * m_impulse)
	set_fixed_process( true )
	m_stage = weakref( get_parent() )


func _fixed_process(delta):
	var bulletBody = get_node("Body2D")
	self.set_pos( get_pos() + bulletBody.get_pos() )
	bulletBody.set_pos( Vector2(0,0) )

	var size = bulletBody.get_colliding_bodies().size()
	for collider in ( bulletBody.get_colliding_bodies() ):
 		get_parent().processBulletCollision( self, collider )
	
	if not bulletBody.get_colliding_bodies().empty():
		self.queue_free()
		var boom = BoomAnimation.instance()
		m_stage.get_ref().add_child( boom )
		boom.set_pos( self.get_pos() )
		boom.get_node("Sprite/AnimationPlayer").connect("finished", boom, "queue_free")
		boom.get_node("Sprite/AnimationPlayer").play("Explode")
	

func rotateToDirection( direction ):
	get_node("Sprite").set_region_rect( Rect2(DIRECTION2SPRITE_X[direction], SPRITE_Y, 8, 16) )
	m_motion = DIRECTION2MOTION[direction]
	
	
var m_team = null
	
func assignTeam(team):
	m_team = team
	self.add_to_group(team)


func getTeam():
	return m_team