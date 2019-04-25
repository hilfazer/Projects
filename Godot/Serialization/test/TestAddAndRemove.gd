extends "./TestBase.gd"

var testResults := []


func _initialize():
	pass


func _runTest():
	var serializer = SerializerGd.new()
	serializer.add( '1', 7.5 )

	testResults.append( serializer.getKeys() != ['1'] )
	testResults.append( serializer.getValue('1') != 7.5 )
	testResults.append( serializer.getValue('g') != null )

	serializer.add( '1', null )
	testResults.append( serializer.getKeys() != [] )

	serializer.add('4', "foo")
	serializer.add('4', "bar")
	testResults.append( serializer.getKeys() != ['4'] )
	testResults.append( serializer.getValue('4') != "bar" )

	serializer.remove('4')
	testResults.append( serializer.getKeys() != [] )


func _validate() -> int:
	return 0 if ( testResults.find( true ) == -1 ) else 1

