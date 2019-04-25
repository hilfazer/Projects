extends "./TestBase.gd"

var nodes := []


func _runTest():
	var results := SerializerGd.serializeTest( self )
	nodes = results.getNodesNoMatchingDeserialize()


func _validate() -> int:
	var passed = nodes.size() == 2 and \
		nodes.find( self ) != -1 and \
		nodes.find( $"Control" ) != -1
	return 0 if passed else 1


func serialize():
	return null
