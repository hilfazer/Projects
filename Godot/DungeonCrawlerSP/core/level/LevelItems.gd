extends Node

var _initialItems := {}


func _ready():
	for item in get_children():
		assert( item is ItemBase )
		_initialItems[ item.name ] = item


func serialize():
	var deletedNames := []

	for itemName in _initialItems:
		assert( itemName is String )
		var itemOnLevel = get_node_or_null( itemName )
		if itemOnLevel == null:
			deletedNames.append( itemName )
			continue
		elif itemOnLevel != _initialItems[itemName]:
			deletedNames.append( itemName )

	return deletedNames


func deserialize( deletedItems : Array ):
	for itemName in deletedItems:
		assert( itemName is String )
		var itemOnLevel = get_node_or_null( itemName )
		if itemOnLevel != null:
			itemOnLevel.queue_free()
			remove_child( itemOnLevel )
