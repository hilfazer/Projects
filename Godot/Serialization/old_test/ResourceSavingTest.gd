extends Node

const PackedFile = "res://save/savedPackedDict.scn"
const NodeToSaveScn = preload("res://old_test/NodeToSave.tscn")

func _ready():
	var toSave = NodeToSaveScn.instance()
	toSave.dict["dict"] = {
		9:1, 8:2, 7:3, {}:{}, 6:4, 5:5, "d":2, 4:6, 3:7, 3.9:1, [5]:0
	}
	toSave.dict["arr"] = [5, 4, "bar"]

	var packed = PackedScene.new()
	var result = packed.pack(toSave)

	if result == OK:
		# warning-ignore:return_value_discarded
		ResourceSaver.save(PackedFile, packed)
		pass

	yield(get_tree(), "idle_frame")

	var loaded = ResourceLoader.load(PackedFile)
	var loadedNode : Node = loaded.instance()

	print(toSave.dict)
	print(loadedNode.dict)
	iteratePrint(toSave.dict["dict"])
	iteratePrint(loadedNode.dict["dict"])
	assert( toSave.dict.hash() == loadedNode.dict.hash() )
	pass


func iteratePrint( dictionary : Dictionary ):
	var string : String
	for elem in dictionary:
		string += (str(elem) + ", ")
	print(string)
