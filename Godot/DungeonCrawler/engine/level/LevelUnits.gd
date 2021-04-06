extends Node

var _initialUnits := {}


func _ready():
	for unit in get_children():
		assert( unit is UnitBase )
		_initialUnits[ unit.name ] = unit


func serialize():
	var deletedNames := []

	for unitName in _initialUnits:
		assert( unitName is String )
		var unitOnLevel = get_node_or_null( unitName )
		if unitOnLevel == null:
			deletedNames.append( unitName )
			continue
		elif unitOnLevel != _initialUnits[unitName]:
			deletedNames.append( unitName )

	return deletedNames


func deserialize( deletedUnits : Array ):
	for unitName in deletedUnits:
		assert( unitName is String )
		var unitOnLevel = get_node_or_null( unitName )
		if unitOnLevel != null:
			unitOnLevel.queue_free()
			remove_child( unitOnLevel )

