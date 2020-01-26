extends "res://core/items/ItemDatabase.gd"


var _items = {
	"HELMET" : {
		"name" : "Helmet",
		"type" : "equipment",
		"defense" : 3,
	}
}


func _createItemsData():
	return _items
