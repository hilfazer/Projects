extends "res://debug/CommandHolder.gd"

onready var _level : LevelBase = get_parent()


func _ready():
	assert( get_parent() is LevelBase )


func _registerCommands():
	registerCommand(
		"setGroundTile",
		"unloads current level",
		[ ['tileName', TYPE_STRING], ['x', TYPE_INT], ['y', TYPE_INT] ]
		)

	registerCommand(
		"listGroundTiles",
		"lists ground tiles' names"
	)

	registerCommand(
		"killUnit",
		"kills a unit",
		[ ['unitName', TYPE_STRING] ]
		)

	registerCommand(
		"destroyItem",
		"destroys an item",
		[ ['itemName', TYPE_STRING] ]
		)


func setGroundTile( tileName, x, y ):
	if -1 !=  _level.get_node("Ground").get_tileset().find_tile_by_name( tileName ):
		_level.get_node("Ground").setTile(tileName, x, y)
	else:
		Console.Log.log(
			"No ground tile named '%s' " % [tileName], Console.Log.TYPE.WARNING )


func listGroundTiles():
	var tileset = _level.get_node("Ground").get_tileset()
	var tileNames := ""
	for id in tileset.get_tiles_ids():
		tileNames += (tileset.tile_get_name(id) + "  ")

	Console.write(tileNames)


func killUnit( unitName : String ):
	var unit := _level.getUnit( unitName )
	if not unit:
		Console.Log.log( "No unit named '%s'" % [unitName], Console.Log.TYPE.WARNING )
	else:
		unit.die()


func destroyItem( itemName : String ):
	var item := _level.getItem( itemName )
	if not item:
		Console.Log.log( "No item named '%s'" % [itemName], Console.Log.TYPE.WARNING )
		return
	else:
		item.destroy()
