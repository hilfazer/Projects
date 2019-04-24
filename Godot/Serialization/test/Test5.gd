# serialize and deserialize

extends Node

const SerializerGd = preload("res://Serializer.gd")

var m_serializer = SerializerGd.new()


func _ready():
	assert( m_serializer.serializeTest($"Node2D").canSave() )

	var ch = Node.new()
	ch.name = "Deserialized"
	add_child(ch)
	m_serializer.deserialize( m_serializer.serialize($"Node2D"), ch )

	if $"Deserialized/Node2D".a != 111:
		print("$Deserialized/Node2D.a != 111")

	if $"Deserialized/Node2D/Node2D3".a != 333:
		print("$Deserialized/Node2D/Node2D3.a != 333")
	pass


