extends ItemDbBase


var _items := {
	"HELMET_BARBUTE" : {
		"name" : "Helmet",
		"type" : "equipment",
		"defense" : 4,
	}
}


func getAllItemsStats() -> Dictionary:
	return _items


func _getDirectory() -> String:
	return get_script().resource_path.get_base_dir()
