extends TileMap


# vector2 with coordinates : tile id
var m_changedTiles = {}


func setTile(tileName, x, y):
	var tileId = get_tileset().find_tile_by_name(tileName)
	set_cell(x, y, tileId)
	m_changedTiles[ Vector2(x,y) ] = tileId


func sendToClient(clientId):
	rpc_id(clientId, "setTiles", m_changedTiles)


slave func setTiles( tiles ):
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
	var tiles = {}
	for tileAndCoords in saveDict.changedTilesCoords:
		tiles[Vector2(tileAndCoords[1], tileAndCoords[2])] = tileAndCoords[0]
		
	setTiles(tiles)
