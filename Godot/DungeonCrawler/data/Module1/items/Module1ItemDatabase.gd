extends "res://core/items/ItemDatabase.gd"


var _items := {
	"HELMET_BARBUTE" : {
		"name" : "Helmet",
		"type" : "equipment",
		"defense" : 4,
	}
}


func _getAllItemsStats() -> Dictionary:
	return _items


func _getDirectory() -> String:
	return get_script().resource_path.get_base_dir()
