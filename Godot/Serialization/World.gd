extends Node

const SerializerGd = preload("res://Serializer.gd")
const Node2DScn = preload("res://Node2D.tscn")

var m_serializer = SerializerGd.new()


func _ready():
	var data1 = m_serializer.serialize( $Parent )
	
	pass


