extends ItemDbBase


var _items := {
	"HELMET" : {
		"name" : "Helmet",
		"type" : "equipment",
		"defense" : 3,
	}
}


func getAllItemsStats() -> Dictionary:
	return _items


func _getDirectory() -> String:
	return get_script().resource_path.get_base_dir()
