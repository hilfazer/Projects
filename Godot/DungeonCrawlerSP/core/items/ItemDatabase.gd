extends Resource

var _itemsData := {}


func _init():
	_itemsData = getItemsData()


func getItemStats(itemId : String) -> Dictionary:
	return {}


func getItemsData() -> Dictionary:
	return {}
