extends "./TestBase.gd"


var testResults
var nodeName : String

func _initialize():
	var node := Node.new()
	node.name = "Child"

	nodeName = node.name

	testResults = SerializerGd.serializeTest( node )
	node.queue_free()


func _validate() -> int:
	var nonInstantiableNodes : Array = testResults.getNotInstantiableNodes()
	if nonInstantiableNodes.size() == 1 and nonInstantiableNodes[0] == nodeName:
		return 0
	else:
		return 1
