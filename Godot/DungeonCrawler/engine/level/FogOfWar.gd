extends TileMap

const FogVisionBaseGd        = preload("./FogVisionBase.gd")

enum TileType { Lit, Shaded, Fogged }

# warning-ignore:unused_class_variable
export(TileType) var fillTile

onready var litTileId    := tile_set.find_tile_by_name("transparent")
onready var shadedTileId := tile_set.find_tile_by_name("grey")
onready var foggedTileId := tile_set.find_tile_by_name("black")
onready var _updateTimer   = $"UpdateTimer"

var _fogVisionsToUpdate := []
var _visionsToResults := {}

var doFogUpdate := false

func _ready():
	_updateTimer.connect( "timeout", self, "requestFogUpdate" )
	_updateTimer.one_shot = true


func _physics_process( _delta ):
	if doFogUpdate:
		_updateFog()
		doFogUpdate = false


func requestFogUpdate():
	doFogUpdate = true


func addFogVision( fogVision : FogVisionBaseGd ) -> int:
	assert( fogVision )
	assert( not fogVision in _visionsToResults )

# warning-ignore:return_value_discarded
	fogVision.connect( "tree_exiting", self, "removeFogVision", [fogVision], CONNECT_ONESHOT )
# warning-ignore:return_value_discarded
	fogVision.connect("changedPosition", self, "onVisionChangedPosition", [fogVision] )
	_insertFogVision( fogVision )
	_updateFog()
	return OK


func removeFogVision( fogVision : FogVisionBaseGd ) -> int:
	assert( fogVision )
	assert( fogVision in _visionsToResults )

	_setTileInRect( shadedTileId, _visionsToResults[fogVision]["tileRect"], self )
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

	_setTileInRect( typeToId[type], rectangle, self )


func getFogVisions() -> Array:
	return _visionsToResults.keys()


func serialize():
	var shadedTiles := get_used_cells_by_id( shadedTileId ) + \
		get_used_cells_by_id( litTileId )
	var uncoveredArray := []

	for tileCoords in shadedTiles:
		uncoveredArray.append( int(tileCoords.x) )
		uncoveredArray.append( int(tileCoords.y) )

	return var2str( uncoveredArray )


func deserialize( data ):
	var uncoveredArray : PoolIntArray = str2var( data )
	for i in uncoveredArray.size() / 2.0:
		set_cell( uncoveredArray[i*2], uncoveredArray[i*2+1], shadedTileId )


func _insertFogVision( fogVision : FogVisionBaseGd ):
	_visionsToResults[ fogVision ] = _makeVisionResult(
		fogVision.boundingRect( self ),
		fogVision.calculateVisibleTiles( self )
		)


func _eraseFogVision( fogVision : FogVisionBaseGd ):
	_visionsToResults.erase( fogVision )
	_fogVisionsToUpdate.erase( fogVision )


func _updateFog():
	#cover fog for nodes that moved
	for vision in _fogVisionsToUpdate:
		assert( vision is FogVisionBaseGd )
		_setTilesWithVisibilityMap(
			_visionsToResults[vision]["tileRect"],
			_visionsToResults[vision]["visibiltyMap"],
			shadedTileId
			)

	_fogVisionsToUpdate.clear()

	#uncover fog for every node
	for vision in _visionsToResults.keys():
		assert( vision is FogVisionBaseGd )
		var tileRect = vision.boundingRect( self )
		var visibilityMap = vision.calculateVisibleTiles( self )
		_setTilesWithVisibilityMap( tileRect, visibilityMap, litTileId )

		_visionsToResults[ vision ] = _makeVisionResult( tileRect, visibilityMap )


func _makeVisionResult( tileRect : Rect2, visibiltyMap ):
	return { "tileRect" : tileRect, "visibiltyMap" : visibiltyMap }


func _setTilesWithVisibilityMap(
		tileRect : Rect2, visibiltyMap : PoolByteArray, tileId : int
		):
	var mapIdx = 0
	for x in range( tileRect.position.x, tileRect.size.x + tileRect.position.x):
		for y in range( tileRect.position.y, tileRect.size.y + tileRect.position.y):
			if visibiltyMap[mapIdx] != 0:
				set_cell(x, y, tileId)
			mapIdx += 1
	pass


static func _setTileInRect( tileId : int, rect : Rect2, fog : TileMap ):
	for x in range( rect.position.x, rect.size.x + rect.position.x):
		for y in range( rect.position.y, rect.size.y + rect.position.y):
			fog.set_cell(x, y, tileId)


static func fogVisionFromNode( node : Node ) -> FogVisionBaseGd:
	for child in node.get_children():
		if child is FogVisionBaseGd:
			return child
	return null
