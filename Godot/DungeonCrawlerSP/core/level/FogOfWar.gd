extends TileMap

const FogVisionBaseGd        = preload("./FogVisionBase.gd")

enum TileType { Lit, Shaded, Fogged }

export var _side := 8   # use an even number
export(TileType) var fillTile

var _rectOffset = Vector2( _side / 2.0, _side / 2.0 )
var _nodesToUpdate := []
onready var _litTileId    := tile_set.find_tile_by_name("transparent")
onready var _shadedTileId := tile_set.find_tile_by_name("grey")
onready var _foggedTileId := tile_set.find_tile_by_name("black")
onready var _updateTimer   = $"UpdateTimer"

# UnitBase to Rect2
var _unitsToVisionRects := {}


func _ready():
	_updateTimer.connect("timeout", self, "_updateFog", [_nodesToUpdate])
	_updateTimer.one_shot = true


func addUnit( unitNode : UnitBase ):
	if _unitsToVisionRects.has( unitNode ):
		return

	_unitsToVisionRects[ unitNode ] = _rectFromNode( unitNode )
	unitNode.connect("changedPosition", self, "onUnitChangedPosition", [unitNode] )
	_updateFog( _unitsToVisionRects.keys() )


func removeUnit( unitNode : UnitBase ):
	_setTileInRect( _shadedTileId, _unitsToVisionRects[unitNode], self )
	_unitsToVisionRects.erase( unitNode )
	unitNode.disconnect("changedPosition", self, "onUnitChangedPosition" )
	_updateFog( _unitsToVisionRects.keys() )


func onUnitChangedPosition( unitNode : UnitBase ):
	if _nodesToUpdate.has( unitNode ):
		return

	_nodesToUpdate.append( unitNode )
	if _nodesToUpdate.size() == 1:
		_updateTimer.start( _updateTimer.wait_time )


func applyFogOfWar( rectangle : Rect2, type : int ):
	var typeToId = {
		  TileType.Lit : _litTileId
		, TileType.Shaded : _shadedTileId
		, TileType.Fogged : _foggedTileId
		}
	assert( type in typeToId )

	for x in range(rectangle.position.x, rectangle.size.x + rectangle.position.x):
		for y in range(rectangle.position.y, rectangle.size.y + rectangle.position.y):
			set_cell( x, y, typeToId[type] )


func serialize():
	var shadedTiles := get_used_cells_by_id( _shadedTileId ) + \
		get_used_cells_by_id( _litTileId )
	var uncoveredArray := []

	for tileCoords in shadedTiles:
		uncoveredArray.append( int(tileCoords.x) )
		uncoveredArray.append( int(tileCoords.y) )

	return var2str( uncoveredArray )


func deserialize( data ):
	var uncoveredArray : Array = str2var( data )
	for i in uncoveredArray.size() / 2.0:
		set_cell( uncoveredArray[i*2], uncoveredArray[i*2+1], _shadedTileId )


func getFogVisionUnits() -> Array:
	return _unitsToVisionRects.keys()


func _updateFog( unitNodes : Array ):
	for unit in unitNodes:
		_setTileInRect( _shadedTileId, _unitsToVisionRects[unit], self )

	#uncover fog for every unit
	for unit in _unitsToVisionRects:
		var pos : Vector2 = world_to_map( unit.global_position )
		pos -= _rectOffset
		_unitsToVisionRects[unit].position = pos
		_setTileInRect( _litTileId, _unitsToVisionRects[unit], self )

	unitNodes.clear()


static func _setTileInRect( tileId : int, rect : Rect2, fog : TileMap ):
	for x in range( rect.position.x, rect.size.x + rect.position.x):
		for y in range( rect.position.y, rect.size.y + rect.position.y):
			fog.set_cell(x, y, tileId)


func _rectFromNode( unitNode : UnitBase ) -> Rect2:
	var rect = Rect2( 0, 0, _side, _side )
	var pos : Vector2 = world_to_map( unitNode.global_position )
	pos -= _rectOffset
	rect.position = pos
	return rect


static func _hasFogVision( unit : UnitBase ) -> bool:
	for child in unit.get_children():
		if child is FogVisionBaseGd:
			return true

	return false

