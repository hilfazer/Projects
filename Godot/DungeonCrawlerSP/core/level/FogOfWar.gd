extends TileMap

const FogVisionBaseGd        = preload("./FogVisionBase.gd")

enum TileType { Lit, Shaded, Fogged }

export(TileType) var fillTile

onready var _litTileId    := tile_set.find_tile_by_name("transparent")
onready var _shadedTileId := tile_set.find_tile_by_name("grey")
onready var _foggedTileId := tile_set.find_tile_by_name("black")
onready var _updateTimer   = $"UpdateTimer"

var _fogVisionsToUpdate := []
var _visionsToBoundingRects := {}


func _ready():
	_updateTimer.connect( "timeout", self, "_updateFog" )
	_updateTimer.one_shot = true


func addFogVision( fogVision : FogVisionBaseGd ) -> int:
	assert( fogVision )
	assert( not fogVision in _visionsToBoundingRects )

	fogVision.connect( "tree_exiting", self, "removeFogVision", [fogVision], CONNECT_ONESHOT )
	fogVision.connect("changedPosition", self, "onVisionChangedPosition", [fogVision] )
	_insertFogVision( fogVision )
	_updateFog()
	return OK


func removeFogVision( fogVision : FogVisionBaseGd ) -> int:
	assert( fogVision )
	assert( fogVision in _visionsToBoundingRects )

	_setTileInRect( _shadedTileId, _visionsToBoundingRects[fogVision], self )
	_eraseFogVision( fogVision )
	fogVision.disconnect("changedPosition", self, "onVisionChangedPosition" )
	_updateFog()
	return OK


func onVisionChangedPosition( fogVision : FogVisionBaseGd ):
	if _fogVisionsToUpdate.has( fogVision ):
		return

	_fogVisionsToUpdate.append( fogVision )
	if _fogVisionsToUpdate.size() == 1:
		_updateTimer.start( _updateTimer.wait_time )


func fillRectWithTile( rectangle : Rect2, type : int ):
	var typeToId = {
		  TileType.Lit : _litTileId
		, TileType.Shaded : _shadedTileId
		, TileType.Fogged : _foggedTileId
		}
	assert( type in typeToId )

	_setTileInRect( typeToId[type], rectangle, self )


func getFogVisionUnits() -> Array:
	return _visionsToBoundingRects.keys()


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


func _insertFogVision( fogVision : FogVisionBaseGd ):
	_visionsToBoundingRects[ fogVision ] = fogVision.boundingRect( self )


func _eraseFogVision( fogVision : FogVisionBaseGd ):
	_visionsToBoundingRects.erase( fogVision )
	_fogVisionsToUpdate.erase( fogVision )


func _updateFog():
	#cover fog for nodes that moved
	for vision in _fogVisionsToUpdate:
		assert( vision is FogVisionBaseGd )
		_setTileInRect( _shadedTileId, _visionsToBoundingRects[vision], self )

	_fogVisionsToUpdate.clear()

	#uncover fog for every node
	for vision in _visionsToBoundingRects.keys():
		assert( vision is FogVisionBaseGd )
		var boundingRect = vision.boundingRect( self )
		#TODO: let vision calculate lit tiles
		_setTileInRect( _litTileId, boundingRect, self )
		_visionsToBoundingRects[vision] = boundingRect


static func _setTileInRect( tileId : int, rect : Rect2, fog : TileMap ):
	for x in range( rect.position.x, rect.size.x + rect.position.x):
		for y in range( rect.position.y, rect.size.y + rect.position.y):
			fog.set_cell(x, y, tileId)


static func fogVisionFromNode( node : Node ) -> FogVisionBaseGd:
	for child in node.get_children():
		if child is FogVisionBaseGd:
			return child
	return null
