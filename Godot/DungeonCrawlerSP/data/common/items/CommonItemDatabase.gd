extends "res://core/items/ItemDatabase.gd"


var _items := {
	"HELMET" : {
		"name" : "Helmet",
		"type" : "equipment",
		"defense" : 3,
	}
}


func _getAllItemsStats() -> Dictionary:
	return _items


func _getDirectory() -> String:
	var dir : String = get_script().resource_path.get_base_dir()
	return dir
