extends ItemDbBase


var _items := {
	"BAZ" : {
		"name" : "Baz",
	},
	"BAR" : {
		"name" : "Bar",
	}
}


func getAllItemsStats() -> Dictionary:
	return _items


func _getDirectory() -> String:
	return get_script().resource_path.get_base_dir()
