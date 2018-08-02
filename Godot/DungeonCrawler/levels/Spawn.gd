extends Position2D

var m_bodiesInArea = 0                 setget deleted


func deleted():
	assert(false)


func _ready():
	m_bodiesInArea = get_node("Area2D").get_overlapping_bodies().size()


func spawnAllowed():
	assert( m_bodiesInArea >= 0 )
	return m_bodiesInArea == 0


func onArea2DBodyEntered( body ):
	m_bodiesInArea += 1


func onArea2DBodyExited( body ):
	m_bodiesInArea -= 1

