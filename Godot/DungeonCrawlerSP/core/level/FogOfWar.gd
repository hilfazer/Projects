extends TileMap

const FogVisionBaseGd        = preload("./FogVisionBase.gd")

enum TileType { Lit, Shaded, Fogged }

export(TileType) var fillTile

onready var litTileId    := tile_set.find_tile_by_name("transparent")
onready var shadedTileId := tile_set.find_tile_by_name("grey")
onready var foggedTileId := tile_set.find_tile_by_name("black")
onready var _updateTimer   = $"UpdateTimer"

var _fogVisionsToUpdate := []
var _visionsToTileIndices := {}


func _ready():
	_updateTimer.connect( "timeout", self, "_updateFog" )
	_updateTimer.one_shot = true


func addFogVision( fogVision : FogVisionBaseGd ) -> int:
	assert( fogVision )
	assert( not fogVision in _visionsToTileIndices )

	fogVision.connect( "tree_exiting", self, "removeFogVision", [fogVision], CONNECT_ONESHOT )
	fogVision.connect("changedPosition", self, "onVisionChangedPosition", [fogVision] )
	_insertFogVision( fogVision )
	_updateFog()
	return OK


func removeFogVision( fogVision : FogVisionBaseGd ) -> int:
	assert( fogVision )
	assert( fogVision in _visionsToTileIndices )

	_setTiles( _visionsToTileIndices[fogVision], shadedTileId, self )
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
		  TileType.Lit : litTileId
		, TileType.Shaded : shadedTileId
		, TileType.Fogged : foggedTileId
		}
	assert( type in typeToId )

	setTileInRect( typeToId[type], rectangle, self )


func getFogVisions() -> Array:
	return _visionsToTileIndices.keys()


func serialize():
	var shadedTiles := get_used_cells_by_id( shadedTileId ) + \
		get_used_cells_by_id( litTileId )
	var uncoveredArray := []

	for tileCoords in shadedTiles:
		uncoveredArray.append( int(tileCoords.x) )
		uncoveredArray.append( int(tileCoords.y) )

	return var2str( uncoveredArray )


func deserialize( data ):
	var uncoveredArray : Array = str2var( data )
	for i in uncoveredArray.size() / 2.0:
		set_cell( uncoveredArray[i*2], uncoveredArray[i*2+1], shadedTileId )


func _insertFogVision( fogVision : FogVisionBaseGd ):
	_visionsToTileIndices[ fogVision ] = fogVision.calculateVisibleTiles( self )


func _eraseFogVision( fogVision : FogVisionBaseGd ):
	_visionsToTileIndices.erase( fogVision )
	_fogVisionsToUpdate.erase( fogVision )


func _updateFog():
	#cover fog for nodes that moved
	for vision in _fogVisionsToUpdate:
		assert( vision is FogVisionBaseGd )
		_setTiles( _visionsToTileIndices[vision], shadedTileId, self )

	_fogVisionsToUpdate.clear()

	#uncover fog for every node
	for vision in _visionsToTileIndices.keys():
		assert( vision is FogVisionBaseGd )
		var visibleTiles : Array = vision.calculateVisibleTiles( self )
		_setTiles( visibleTiles, litTileId, self )
		_visionsToTileIndices[vision] = visibleTiles


static func _setTiles( tileIndices : Array, tileId : int, fog ):
	for coords in tileIndices:
		fog.set_cellv(coords, tileId)


static func setTileInRect( tileId : int, rect : Rect2, fog : TileMap ):
	for x in range( rect.position.x, rect.size.x + rect.position.x):
		for y in range( rect.position.y, rect.size.y + rect.position.y):
			fog.set_cell(x, y, tileId)


static func fogVisionFromNode( node : Node ) -> FogVisionBaseGd:
	for child in node.get_children():
		if child is FogVisionBaseGd:
			return child
	return null
