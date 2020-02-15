extends Resource

const ItemFilesFinder = preload("res://core/items/ItemFilesFinder.gd")

var _filesFinder = ItemFilesFinder.new()
var _itemsData := {}


func _init():
	_itemsData = getItemsData()


func getItemStats(itemId : String) -> Dictionary:
	return {}


func getItemsData() -> Dictionary:
	return {}
