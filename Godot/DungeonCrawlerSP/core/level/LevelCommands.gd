extends "res://debug/CommandHolder.gd"

onready var _level : LevelBase = get_parent()


func _ready():
	assert( get_parent() is LevelBase )


func _registerCommands():
	registerCommand( "setGroundTile",
	{
		'description' : "unloads current level",
		'args':[ ['tileName', TYPE_STRING], ['x', TYPE_INT], ['y', TYPE_INT] ],
		'target' : [self, "setGroundTile"]
	} )
	registerCommand( "killUnit",
	{
		'description' : "kills a unit",
		'args':[ ['unitName', TYPE_STRING] ],
		'target' : [self, "killUnit"]
	} )


func setGroundTile( tileName, x, y ):
	if -1 !=  _level.get_node("Ground").get_tileset().find_tile_by_name( tileName ):
		_level.get_node("Ground").setTile(tileName, x, y)
	else:
		Console.Log.log(
			"No ground tile named '%s' " % [tileName], Console.Log.TYPE.WARNING )


func killUnit( unitName : String ):
	var unit := _level.getUnit( unitName )
	if not unit:
		Console.Log.log( "No unit named '%s'" % [unitName], Console.Log.TYPE.WARNING )
		return
	else:
		unit.die()
