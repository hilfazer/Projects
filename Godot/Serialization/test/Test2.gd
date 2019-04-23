# noninstantiable nodes

extends Node

const SerializerGd = preload("res://Serializer.gd")

var m_serializer = SerializerGd.new()


func _ready():
	var unsavableNode = Control.new()
	unsavableNode.name = "UnsavableNode"
	add_child(unsavableNode)

	var unsavableNode2 = Control.new()
	unsavableNode2.name = "UnsavableNode2"
	add_child(unsavableNode2)
	var result = m_serializer.serializeTest(self)

	if result.getNotInstantiableNodes().size() != 2:
		print("result.getNotInstantiableNodes().size() != 2")

	if result.nodesForbiddenKeys.size() != 0:
		print("result.nodesForbiddenKeys.size() != 0")

	if not result.canSave():
		print("not canSave()")
