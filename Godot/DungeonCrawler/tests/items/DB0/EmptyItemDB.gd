extends ItemDbBase


func getAllItemsStats() -> Dictionary:
	return {}


func _getDirectory() -> String:
	return get_script().resource_path.get_base_dir()
