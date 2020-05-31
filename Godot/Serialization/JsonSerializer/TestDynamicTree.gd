extends "./TestBase.gd"

const ToFloatGd = preload("./SerializeToFloat.gd")
const ToDictGd = preload("./SerializeToDict.gd")

onready var _saveRoot : Node = Node.new()
var _toFloatNode : ToFloatGd
var _toDictNode : ToDictGd
var _removedNodePath : NodePath


func _initialize():
	add_child( _saveRoot )

	_toDictNode = ToDictGd.new()
	_saveRoot.add_child( _toDictNode )
	_toDictNode.f = 3.1
	_toDictNode.s = "godot"

	_toFloatNode = ToFloatGd.new()
	_toDictNode.add_child( _toFloatNode )
	_toFloatNode.f = 5.5


func _runTest():
	var serializer = SerializerGd.new()
	serializer.add( _testName, SerializerGd.serialize( _saveRoot ) )
	serializer.saveToFile( _saveFilename, true )

	_toFloatNode.f = 0.0
	_removedNodePath = _toFloatNode.get_path()
	_toFloatNode.free()

	serializer = SerializerGd.new()
	serializer.loadFromFile( _saveFilename )
	# warning-ignore:return_value_discarded
	SerializerGd.deserialize( serializer.getValue( _testName ), self )


func _validate() -> int:
	var passed = not has_node( _removedNodePath ) \
		and _toDictNode.f == 3.1 \
		and _toDictNode.s == "godot"

	return 0 if passed else 1
