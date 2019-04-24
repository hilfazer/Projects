extends "./TestBase.gd"

var testResults
var childPath : NodePath

func _initialize():
	var node := Node.new()
	node.name = "Child"
	add_child( node )
	childPath = node.get_path()


	testResults = SerializerGd.serializeTest( self )


func _validate() -> int:
	var nonInstantiableNodes : Array = testResults.getNotInstantiableNodes()
	if nonInstantiableNodes.size() == 1 and nonInstantiableNodes[0] == childPath:
		return 0
	else:
		return 1
