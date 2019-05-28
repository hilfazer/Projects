extends Node2D

onready var _lastPosition := global_position

signal changedPosition()


func _process( _delta ):
	if global_position != _lastPosition:
		emit_signal( 'changedPosition' )
		_lastPosition = global_position


func boundingRect( fogOfWar : TileMap ) -> Rect2:
	assert( false )
	return Rect2()

