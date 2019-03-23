extends TileMap


# vector2 with coordinates : tile id
var _changedTiles : Dictionary = {}


func setTile(tileName, x, y):
	var tileId = get_tileset().find_tile_by_name(tileName)
	set_cell(x, y, tileId)
	_changedTiles[ Vector2(x,y) ] = tileId


func setTiles( tiles : Dictionary ):
	for coords in tiles:
		set_cell(coords.x, coords.y, tiles[coords])
		_changedTiles[coords] = tiles[coords]


func serialize():
	var saveDict = {
		changedTilesCoords = []
	}

	for tile in _changedTiles:
		saveDict.changedTilesCoords.append([_changedTiles[tile], tile.x, tile.y])

	return saveDict


func deserialize(saveDict):
	var tiles : Dictionary = {}
	for tileAndCoords in saveDict.changedTilesCoords:
		tiles[Vector2(tileAndCoords[1], tileAndCoords[2])] = tileAndCoords[0]

	setTiles(tiles)
