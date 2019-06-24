extends Node2D

onready var _lastPosition := global_position

signal changedPosition()


func _init():
	name = get_script().resource_path.get_basename().get_file()


func _process( _delta ):
	if global_position != _lastPosition:
		emit_signal( 'changedPosition' )
		_lastPosition = global_position


func uncoverFogTiles(fogOfWar : TileMap ):
	assert( false )


func calculateVisibleTiles(fogOfWar : TileMap ) -> Array:
	assert( false )
	return Array()


func boundingRect( fogOfWar : TileMap ) -> Rect2:
	assert( false )
	return Rect2()
