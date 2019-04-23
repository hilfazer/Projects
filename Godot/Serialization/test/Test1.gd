# nodes with forbidden keys

extends Node

const SerializerGd = preload("res://Serializer.gd")

#var m_serializer = SerializerGd.new()


func _ready():
	var result = SerializerGd.serializeTest(self)

	if result.nodesForbiddenKeys.size() != 3:
		print("result.nodesForbiddenKeys.size() != 3")

	if result.getNotInstantiableNodes().size() != 0:
		print("result.getNotInstantiableNodes().size() != 0")

	if result.canSave():
		print("canSave()")
