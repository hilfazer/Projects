extends TileMap


var m_changedTiles = {}


func setTile(tileName, x, y):
	var tileId = get_tileset().find_tile_by_name(tileName)
	set_cell(x, y, tileId)
	m_changedTiles[ Vector2(x,y) ] = tileId


func sendToPlayer(playerId):
	rpc_id(playerId, "setTiles", m_changedTiles)
	
	
remote func setTiles( tiles ):
	for coords in tiles:
		set_cell(coords.x, coords.y, tiles[coords])
		m_changedTiles[coords] = tiles[coords]