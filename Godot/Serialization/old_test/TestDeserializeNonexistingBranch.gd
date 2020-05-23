extends "./TestBase.gd"

const BranchScn = preload("./5NodeBranch.tscn")
const ToFloatGd = preload("./SerializeToFloat.gd")
const ToStringGd = preload("./SerializeToString.gd")
const ToArrayGd = preload("./SerializeToArray.gd")
const ToDictGd = preload("./SerializeToDict.gd")


var spatial  : ToDictGd
var timer : ToFloatGd
var colorRect  : ToStringGd
var world   : ToArrayGd
var branchName : String

func _initialize():
	_addBranch(BranchScn)
	_setupReferences()

	spatial.f = 3.3
	spatial.s = "qwe"
	timer.f = 7.0
	colorRect.s = "ll"
	world.f = 1.2
	world.i = 200


func _runTest():
	var serializedData = SerializerGd.serialize( get_node(branchName) )

	get_node(branchName).free()
	assert( not has_node(branchName) )

	var serializer := SerializerGd.new()
	serializer.add( _testName, serializedData )
	var saveResult = serializer.saveToFile( _saveFilename, true )
	assert( saveResult == OK )
	var loadResult = serializer.loadFromFile( _saveFilename )
	assert( loadResult == OK )
	var loadedData = serializer.getValue( _testName )

	# warning-ignore:return_value_discarded
	SerializerGd.deserialize( loadedData, self )
	_setupReferences()


func _validate() -> int:
	var passed = has_node( "Spatial/Bone2D/WorldEnvironment" ) \
		and spatial.f == 3.3 \
		and spatial.s == "qwe" \
		and timer.f == 7.0 \
		and colorRect.s == "ll" \
		and world.f == 1.2 \
		and world.i == 200

	return 0 if passed else 1


func _addBranch( branchRes : Resource ):
	var branch = branchRes.instance()
	add_child( branch )
	branchName = branch.name


func _setupReferences():
	spatial = $"Spatial"
	timer = $"Spatial/Timer"
	colorRect = $"Spatial/Timer/ColorRect"
	world = $"Spatial/Bone2D/WorldEnvironment"

