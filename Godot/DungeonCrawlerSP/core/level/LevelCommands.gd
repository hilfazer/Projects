extends "res://debug/CommandHolder.gd"

const LevelBaseGd            = preload("./LevelBase.gd")


func _ready():
	assert( get_parent() is LevelBaseGd )


func _registerCommands():
	if not is_network_master():
		return

	registerCommand("setTile", {
		'description' : "unloads current level",
		'args':[ ['tileName', TYPE_STRING], ['x', TYPE_INT], ['y', TYPE_INT] ],
		'target' : [self, "setTile"]
	} )


func setTile( tileName, x, y ):
	if -1 !=  $"../Ground".get_tileset().find_tile_by_name( tileName ):
		$"../Ground".setTile(tileName, x, y)
