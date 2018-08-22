# serialize and deserialize with saving to a file

extends Node

const SerializerGd = preload("res://Serializer.gd")
const SaveFilename = "res://save/test6.save"

var m_serializer = SerializerGd.new()


func _ready():
	assert( m_serializer.serializeTest($"Node2D").canSave() )

	var serializedKeyValue = SerializerGd.serialize($Node2D)
	m_serializer.add( SerializerGd.serialize($Node2D) )
	m_serializer.saveToFile( SaveFilename )
	$Node2D.free()
	m_serializer.loadFromFile( SaveFilename )
	
	var deserializedKeyValue = m_serializer.get("Node2D")
	
	if !deserializedKeyValue[1].has_all( serializedKeyValue[1].keys() ) or \
		!serializedKeyValue[1].has_all( deserializedKeyValue[1].keys() ):
		print( "dictionaries are not equal" )
	SerializerGd.deserialize( deserializedKeyValue, self )

	if $Node2D/Node2D2.a != 33:
		print("$Deserialized/Node2D/Node2D2.a != 33")


