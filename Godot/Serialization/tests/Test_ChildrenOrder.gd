extends "res://tests/files/GutTestBase.gd"

const SerializerGd           = preload("res://HierarchicalSerializer.gd")
const Scene1Scn              = preload("res://tests/files/Scene1.tscn")


func test_saveAndLoadChildrenOrder():
	randomize()
	var saveFile = "user://saveAndLoadChildrenOrder.tres"
	var namesArray := []
	var intsArray := []

	for i in range(30):
		var randomNumber = randi() % 10000
		namesArray.append( str(randomNumber) )
		intsArray.append( i )

	yield( get_tree(), "idle_frame" )

	var topChild = Scene1Scn.instance()
	topChild.name = "topChild"
	add_child( topChild )

	for i in range( namesArray.size() ):
		var node = Scene1Scn.instance()
		node.name = namesArray[i]
		node.ii = intsArray[i]
		topChild.add_child( node )

	var serializer = SerializerGd.new()
	serializer.addSerialized( "topKey", serializer.serialize( topChild ) )
	serializer.saveToFile( saveFile )

	topChild.name = "oldChild"
	serializer.loadFromFile( saveFile )
	serializer.deserialize( serializer.getSerialized("topKey"), self )

	var loadedNamesArray := []
	var loadedIntsArray := []
	for child in $"topChild".get_children():
		loadedNamesArray.append( child.name )
		loadedIntsArray.append( child.ii )

	assert_eq( namesArray, loadedNamesArray )
	assert_eq( intsArray, loadedIntsArray )
