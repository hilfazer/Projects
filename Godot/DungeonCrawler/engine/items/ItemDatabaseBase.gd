extends Resource
class_name ItemDbBase

const FilesFinderGd          = preload("res://projects/FileFinder/FileFinder.gd")

const ITEM_ID                = "_itemID"

var _idsToFilepaths:         = {}

# create instances of ItemDbBase with ItemDbFactory.gd


func getItemStats(itemId : String) -> Dictionary:
	assert(_idsToFilepaths.has(itemId))
	return getAllItemsStats()[itemId]


func getAllItemsStats() -> Dictionary:
	assert(false)
	return {}


func setupItemDatabase( errorMessages: Array ) -> void:
	var idsToFilepaths := {}
	var itemStats := getAllItemsStats()
	var sceneFiles := FilesFinderGd.findFilesInDirectory(
			_getDirectory(), Globals.SCENE_EXTENSION )

	for itemFile in sceneFiles:
		var itemId = findIdInItemFile( itemFile )
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

	_idsToFilepaths = idsToFilepaths


func _getDirectory() -> String:
	assert(false)
	return ""


static func findIdInItemFile( itemFile: String ) -> String:
	var rootNodeId = 0
	var packedItem : Resource = load(itemFile)
	if not packedItem is PackedScene:
		Debug.error(null, "Resource is not a PackedScene")
		return ItemBase.INVALID_ID

	var state = packedItem.get_state()
	for propIdx in range(0, state.get_node_property_count(rootNodeId) ):
		var pname : String = state.get_node_property_name(rootNodeId, propIdx)
		if pname == ITEM_ID:
			return state.get_node_property_value(rootNodeId, propIdx)

	return ItemBase.INVALID_ID


static func checkForDuplictates( baseA, baseB ) -> PoolStringArray:
	var duplicatedIds := PoolStringArray()
	var baseAindices : Array = baseA.getAllItemsStats().keys()
	var baseBindices : Array = baseB.getAllItemsStats().keys()
	for index in baseBindices:
		assert( index is String )
		if baseAindices.has( index ):
			duplicatedIds.append( index )

	return duplicatedIds


