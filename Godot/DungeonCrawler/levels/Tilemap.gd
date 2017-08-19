extends TileMap


var m_changedTiles = {}


func setTile(tileName, x, y):
	var tileId = get_tileset().find_tile_by_name(tileName)
	set_cell(x, y, tileId)
	m_changedTiles[ Vector2(x,y) ] = tileId
