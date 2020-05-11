extends Node
class_name ItemBase

const INVALID_ID = ""

export var _itemID : String
export var _durability : int


func _ready():
	assert(_itemID != INVALID_ID)


func getID() -> String:
	return _itemID


func getDurability() -> int:
	return _durability
