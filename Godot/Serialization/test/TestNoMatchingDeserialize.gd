extends "./TestBase.gd"

var nodesNoMatchingDeserialize := []


func _runTest():
	var results := SerializerGd.serializeTest( self )
	nodesNoMatchingDeserialize = results.getNodesNoMatchingDeserialize()

	var serializer = SerializerGd.new()
	var savedData = SerializerGd.serialize( self )

	serializer.add( _testName, savedData )
	serializer.saveToFile( _saveFilename, true )

	if OK == serializer.loadFromFile( _saveFilename ):
		var loadedData = serializer.getValue( _testName )
		# warning-ignore:return_value_discarded
		SerializerGd.deserialize( loadedData, get_parent() )


func _validate() -> int:
	var passed = nodesNoMatchingDeserialize.size() == 2 \
		and nodesNoMatchingDeserialize.find( self ) != -1 \
		and nodesNoMatchingDeserialize.find( $"Control" ) != -1
	return 0 if passed else 1


func serialize():
	return null
