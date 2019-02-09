extends TileMap


# vector2 with coordinates : tile id
var m_changedTiles : Dictionary = {}


func setTile(tileName, x, y):
	var tileId = get_tileset().find_tile_by_name(tileName)
	set_cell(x, y, tileId)
	m_changedTiles[ Vector2(x,y) ] = tileId


puppet func setTiles( tiles : Dictionary ):
	for coords in tiles:
		set_cell(coords.x, coords.y, tiles[coords])
		m_changedTiles[coords] = tiles[coords]


func serialize():
	var saveDict = {
		changedTilesCoords = []
	}

	for tile in m_changedTiles:
		saveDict.changedTilesCoords.append([m_changedTiles[tile], tile.x, tile.y])

	return saveDict


func deserialize(saveDict):
	var tiles : Dictionary = {}
	for tileAndCoords in saveDict.changedTilesCoords:
		tiles[Vector2(tileAndCoords[1], tileAndCoords[2])] = tileAndCoords[0]

	setTiles(tiles)
