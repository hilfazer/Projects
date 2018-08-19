# serialization of node inside tree

extends Node

const SerializerGd = preload("res://Serializer.gd")

var m_serializer = SerializerGd.new()

func _ready():
	var ch = Node2D.new()
	add_child( ch )
	ch.set_script( $Node2D.get_script() )
	
	var result = SerializerGd.serializeTest(self)
	if not result.canSave():
		print("not canSave()")
		
	if result.nodesNonserializable.size() != 1:
		print("result.nodesNonserializable.size() != 1")

	var data = m_serializer.serialize( self )
	
	if data['CHILDREN'].size() != 1:
		print("data['CHILDREN'].size() != 1")

	if data['CHILDREN']['Node2D']['CHILDREN'].size() != 2:
		print("data['CHILDREN']['Node2D']['CHILDREN'].size() != 2")
	pass


var a = 24

func serialize():
	return {0 : a}


func deserialize( dict ):
	a = dict[0]
