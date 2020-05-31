extends Node2D

const VisibilityLayer = 0x00000010

onready var _lastPosition := global_position

signal changedPosition()


func _init():
	allowInstantiation()

	name = get_script().resource_path.get_basename().get_file()


func _process( _delta ):
	if global_position != _lastPosition:
		emit_signal( 'changedPosition' )
		_lastPosition = global_position


func allowInstantiation():
	assert(false)


# warning-ignore:unused_argument
func calculateVisibleTiles( fogOfWar : TileMap ) -> PoolByteArray:
	assert( false )
	return PoolByteArray()


# warning-ignore:unused_argument
func boundingRect( fogOfWar : TileMap ) -> Rect2:
	assert( false )
	return Rect2()


# warning-ignore:unused_argument
func setExcludedRID( rid : RID ):
	pass
