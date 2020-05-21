extends Node

const DictSerializerGd = preload("res://test/DictBasedSerializer.gd")
const ArraySerializerGd = preload("res://JsonArraySerializer.gd")


func _ready():
	call_deferred("savePackedScene")
	call_deferred("saveDictBasedTree")
	call_deferred("saveArrayBasedTree")
	call_deferred("saveFlat")


func savePackedScene():
	_populateWithDuplicates( $"NodeName1")

	var scene = PackedScene.new()
	var result = scene.pack( $"NodeName1" )
	if result == OK:
		# warning-ignore:return_value_discarded
		ResourceSaver.save("res://save/savedPacked.scn", scene)
		pass


func saveDictBasedTree():
	_populateWithDuplicates( $"NodeName2")

	var serializer = DictSerializerGd.new()
	var data = serializer.serialize( $"NodeName2" )
	var saveFile = File.new()

	if OK != saveFile.open("res://save/saveDictBasedTree.json", File.WRITE):
		return

	saveFile.store_line(to_json(data))
	saveFile.close()


func saveArrayBasedTree():
	_populateWithDuplicates( $"NodeName3" )

	var serializer = ArraySerializerGd.new()
	var data = serializer.serialize( $"NodeName3" )
	var saveFile = File.new()

	if OK != saveFile.open("res://save/saveArrayBasedTree.json", File.WRITE):
		return

	saveFile.store_line(to_json(data))
	saveFile.close()


func saveFlat():
	_populateWithDuplicates( $"NodeName4" )

	var saveFile = File.new()
	if OK != saveFile.open("res://save/saveFlat.json", File.WRITE):
		return

	var data := {}
	data[ name ] = $"NodeName4".serialize()
	for child in $"NodeName4".get_children():
		data[child.get_path()] = child.serialize()

	saveFile.store_line(to_json(data))
	saveFile.close()


func _populateWithDuplicates( parent : Node ):
	var prototype = parent.duplicate()
	# warning-ignore:unused_variable
	for i in range( 0, 300 ):
		var node = prototype.duplicate()
		parent.add_child( node, true )
		node.owner = parent

	prototype.free()
