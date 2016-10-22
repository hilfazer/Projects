
extends Node2D

const SPEED = 300
const SPRITE_Y = 96
const DIRECTION2SPRITE_X = { 2 : 320+16, 4 : 320+8, 6 : 320+24, 8 : 320 }
const DIRECTION2MOTION = { 2 : Vector2(0, 1), 4 : Vector2(-1, 0), 6 : Vector2(1, 0), 8 : Vector2(0, -1)}


var motion = Vector2(0, -1)


func _ready():
	set_process( true )
	
	var bulletBody = get_node("Body2D")
	bulletBody.apply_impulse( Vector2(0,1), motion.normalized()*SPEED)
	set_fixed_process( true )


func _fixed_process(delta):
	var bulletBody = get_node("Body2D")
	self.set_pos( get_pos() + bulletBody.get_pos() )
	bulletBody.set_pos( Vector2(0,0) )

	var size = bulletBody.get_colliding_bodies().size()
	for collider in ( bulletBody.get_colliding_bodies() ):
		get_parent().processBulletCollision( self, collider )
	
	if not bulletBody.get_colliding_bodies().empty():
		self.queue_free()
	

func rotate( direction ):
	get_node("Sprite").set_region_rect( Rect2(DIRECTION2SPRITE_X[direction], SPRITE_Y, 8, 16) )
	motion = DIRECTION2MOTION[direction]
	
	
	
	