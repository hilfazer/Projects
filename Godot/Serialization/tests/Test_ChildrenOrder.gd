extends "res://tests/GutTestBase.gd"

const SerializerGd           = preload("res://HierarchicalSerializer.gd")
const Scene1Scn              = preload("res://tests/files/Scene1.tscn")


func test_saveAndLoadChildrenOrder():
	randomize()
	var saveFile = _createDefaultTestFilePath("tres")

	yield( get_tree(), "idle_frame" )

	var topChild = Scene1Scn.instance()
	topChild.name = "topChild"
	add_child( topChild )

	var intsArray : PoolIntArray = range(2, 33)
	for i in intsArray:
		var node = Scene1Scn.instance()
		node.name = str( randi() % 10000 )
		node.ii = i
		topChild.add_child( node, true )

	var serializer := SerializerGd.new()
	assert_true( serializer.addAndSerialize( "topKey", topChild ) )
	assert_eq( OK, serializer.saveToFile( saveFile ) )

	topChild.name = "oldChild"
	assert_eq( OK, serializer.loadFromFile( saveFile ) )
# warning-ignore:return_value_discarded
	serializer.getAndDeserialize( "topKey", self )

	var oldNamesArray := PoolStringArray()
	for child in topChild.get_children():
		oldNamesArray.append( child.name )

	var loadedNamesArray := PoolStringArray()
	var loadedIntsArray := PoolIntArray()
	for child in $"topChild".get_children():
		loadedNamesArray.append( child.name )
		loadedIntsArray.append( child.ii )

	assert_eq( oldNamesArray, loadedNamesArray )
	assert_eq( intsArray, loadedIntsArray )

