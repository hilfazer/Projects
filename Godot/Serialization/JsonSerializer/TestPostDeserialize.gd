extends "./TestBase.gd"

const PostDeserializeGd = preload("./PostDeserialize.gd")


func _initialize():
	($"PostDeserialize" as PostDeserializeGd).i = 8


func _runTest():
	var serializedData = SerializerGd.serialize( $"PostDeserialize" )

	($"PostDeserialize" as PostDeserializeGd).i = 0

	# warning-ignore:return_value_discarded
	SerializerGd.deserialize( serializedData, self )


func _validate() -> int:
	return 0 if ($"PostDeserialize".i == 8 and $"PostDeserialize".ii == 8) else 1
