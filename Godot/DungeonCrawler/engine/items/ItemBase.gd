extends Node
class_name ItemBase

const INVALID_ID := ""

export var _itemID : String = INVALID_ID


func _init():
	Debug.updateVariable("Item count", +1, true)


func _ready():
	assert(_itemID != INVALID_ID)


func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		Debug.updateVariable("Item count", -1, true)


func getID() -> String:
	return _itemID


func destroy():
	queue_free()
