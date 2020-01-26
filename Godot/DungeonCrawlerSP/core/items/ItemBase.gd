extends Node
class_name ItemBase

export var _ID : String
export var _durability : int


func _ready():
	assert(_ID != "")


func getID() -> String:
	return _ID


func getDurability() -> int:
	return _durability
