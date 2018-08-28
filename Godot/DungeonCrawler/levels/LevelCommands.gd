extends Node

const LevelBaseGd            = preload("./LevelBase.gd")


func _ready():
	assert( get_parent() is LevelBaseGd )
	_registerCommands()


func _registerCommands():
	if not is_network_master():
		return

	var setTile = "setTile"
	Console.register(setTile, {
		'description' : "unloads current level",
		'args':[ ['tileName', TYPE_STRING] ],
		'target' : [self, setTile]
	} )
	connect( "tree_exiting", Console, "deregister", [setTile] )


func setTile( tileName ):
	get_parent().get_node("Ground").setTile(tileName, 5, 5)
