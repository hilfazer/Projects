extends "res://debug/CommandHolder.gd"


func _ready():
	assert( get_parent() is LevelBase )


func _registerCommands():
	registerCommand( "setTile",
	{
		'description' : "unloads current level",
		'args':[ ['tileName', TYPE_STRING], ['x', TYPE_INT], ['y', TYPE_INT] ],
		'target' : [self, "setTile"]
	} )


func setTile( tileName, x, y ):
	if -1 !=  $"../Ground".get_tileset().find_tile_by_name( tileName ):
		$"../Ground".setTile(tileName, x, y)

