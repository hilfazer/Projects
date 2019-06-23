extends "res://core/level/FogVisionBase.gd"


export var _side := 20        setget setSide
var _excludedRID : RID       setget setExcludedRID

var _rectOffset = Vector2( _side / 2.0, _side / 2.0 )


func _ready():
	# hack
	setExcludedRID( get_parent().get_rid() )


func uncoverFogTiles(fogOfWar : TileMap ):
	var center := global_position
	var spaceState := get_world_2d().direct_space_state
	var rect := boundingRect(fogOfWar)

	for line in lines:
		line.queue_free()
	lines.clear()

	for x in range( rect.position.x, rect.size.x + rect.position.x):
		for y in range( rect.position.y, rect.size.y + rect.position.y):
			var targetPosition = _tileToPixelCenter(x, y, fogOfWar)
			var occlusion = spaceState.intersect_ray( center, targetPosition, [_excludedRID] )
			var line = Line2D.new()
			line.add_point(center)
			line.add_point(targetPosition)
			line.width = 1.5
			line.default_color = Color.red if occlusion else Color.azure
			line.default_color.a = .1
			lines.append(line)
			fogOfWar.add_child(line)


func boundingRect( fogOfWar : TileMap ) -> Rect2:
	var rect = Rect2( 0, 0, _side, _side )
	var pos : Vector2 = fogOfWar.world_to_map( global_position )
	pos -= _rectOffset
	rect.position = pos
	return rect


func setSide( side : int ):
	_side = side if side % 2 == 0 else side + 1


func setExcludedRID( rid : RID ):
	_excludedRID = rid


func _tileToPixelCenter(x, y, fogOfWar : TileMap):
	var corner := fogOfWar.map_to_world(Vector2(x, y))
	return corner + fogOfWar.cell_size / 2


#debug stuff
var lines := []

