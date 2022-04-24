extends Resource

const ItemFilesFinderGd      = preload("res://projects/FileFinder/FileFinder.gd")

var _idsToFilepaths := {}
var initialized : bool = false


func initialize() -> Array:
	var errors := []
	if isInitialized():
		errors.append("Item database already initialized")
		return errors

	_idsToFilepaths = _setupDatabase( errors )
	initialized = true
	return errors


func isInitialized() -> bool:
	return initialized


func getItemStats(itemId : String) -> Dictionary:
	assert(_idsToFilepaths.has(itemId))
	return _getAllItemsStats()[itemId]


func _getAllItemsStats() -> Dictionary:
	assert(false)
	return {}


func _getDirectory() -> String:
	assert(false)
	return ""


func _setupDatabase( errorMessages : Array ) -> Dictionary:
	var idsToFilepaths := {}
	var itemStats := _getAllItemsStats()
	var itemFiles := ItemFilesFinderGd.findFilesInDirectory(
			_getDirectory(), Globals.SCENE_EXTENSION )

	for itemFile in itemFiles:
		var itemId = _findIdInItemFile( itemFile )
		var noErrors := true
		if itemId == ItemBase.INVALID_ID:
			errorMessages.append( "No valid item id in file: %s" % itemFile )
			noErrors = false
		if idsToFilepaths.has(itemId):
			errorMessages.append( "Duplicated item id %s in file: %s" % [itemId, itemFile] )
			noErrors = false
		if not itemStats.has(itemId):
			errorMessages.append( "No item stats for id '%s' " % itemId )
			noErrors = false

		if noErrors:
			idsToFilepaths[itemId] = itemFile

	return idsToFilepaths


func _findIdInItemFile( itemFile : String ) -> String:
	var rootNodeId = 0
	var packedItem : Resource = load(itemFile)
	assert( packedItem )
	var state = packedItem.get_state()
	for propIdx in range(0, state.get_node_property_count(rootNodeId) ):
		var pname : String = state.get_node_property_name(rootNodeId, propIdx)
		if pname == "_itemID":
			return state.get_node_property_value(rootNodeId, propIdx)

	return ItemBase.INVALID_ID


static func checkForDuplictates( baseA, baseB ) -> PoolStringArray:
	assert( baseA.isInitialized() )
	assert( baseB.isInitialized() )

	var duplicatedIds := PoolStringArray()
	var baseAindices : Array = baseA._getAllItemsStats().keys()
	var baseBindices : Array = baseB._getAllItemsStats().keys()
	for index in baseBindices:
		assert( index is String )
		if baseAindices.has( index ):
			duplicatedIds.append( index )

	return duplicatedIds


