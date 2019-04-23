extends Node

const SerializerGd = preload("res://Serializer.gd")
const Node2DScn = preload("res://test/Node2D.tscn")


func _ready():
	call_deferred("populate")
	call_deferred("savePackedScene")
	call_deferred("saveSerializedTree")
	call_deferred("saveSerializedFlat")
	pass


func populate():
	for i in range(0,300):
		var n = Node2DScn.instance()
		add_child(n, true)
		n.owner = self


func savePackedScene():
	var scene = PackedScene.new()
	var result = scene.pack(self)
	if result == OK:
		ResourceSaver.save("res://save/savedPacked.scn", scene)
		pass


func saveSerializedTree():
	var serializer = SerializerGd.new()
	var data = serializer.serialize( self )
	var saveFile = File.new()

	if OK != saveFile.open("res://save/savedTree.json", File.WRITE):
		return

	saveFile.store_line(to_json(data))
	saveFile.close()


func saveSerializedFlat():
	var saveFile = File.new()

	if OK != saveFile.open("res://save/savedFlat.json", File.WRITE):
		return

	var data := {}
	data[ name ] = serialize()
	for child in get_children():
		data[child.get_path()] = child.serialize()

	saveFile.store_line(to_json(data))
	saveFile.close()


func serialize():
	return {
		"SCENE" : filename,
		"CHILDREN" : { }
	}
