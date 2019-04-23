# serialization of node outside of tree

extends Node

const SerializerGd = preload("res://Serializer.gd")

var m_serializer = SerializerGd.new()

const scene = "res://test/Node2D_3children.tscn"

func _ready():
	var nodeOutsideOfTree = preload(scene).instance()

	var nameAndData = m_serializer.serialize( nodeOutsideOfTree )

	if nameAndData[1]['CHILDREN'].size() != 2:
		print("data['CHILDREN'].size() != 2")


	nodeOutsideOfTree.queue_free()
	pass

