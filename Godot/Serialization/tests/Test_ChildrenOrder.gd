extends "res://tests/files/GutTestBase.gd"

const SerializerGd           = preload("res://HierarchicalSerializer.gd")
const Scene1Scn              = preload("res://tests/files/Scene1.tscn")


func test_saveAndLoadChildrenOrder():
	randomize()
	var saveFile = _createDefaultTestFilePath("tres")

	yield( get_tree(), "idle_frame" )

	var topChild = Scene1Scn.instance()
	topChild.name = "topChild"
	add_child( topChild )

	var intsArray := range(2, 33)
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

	var oldNamesArray := []
	for child in topChild.get_children():
		oldNamesArray.append( child.name )

	var loadedNamesArray := []
	var loadedIntsArray := []
	for child in $"topChild".get_children():
		loadedNamesArray.append( child.name )
		loadedIntsArray.append( child.ii )

	assert_eq( oldNamesArray, loadedNamesArray )
	assert_eq( intsArray, loadedIntsArray )

