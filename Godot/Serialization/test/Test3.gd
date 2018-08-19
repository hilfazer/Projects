# serialization of node inside tree

extends Node

const SerializerGd = preload("res://Serializer.gd")

var m_serializer = SerializerGd.new()


func _ready():
	var ch = Node2D.new()
	ch.name = "NewedNode"
	var ch2 = ch.duplicate()
	ch.set_script( $Node2D.get_script() )
	ch.name = ch.name + "WithSerialize"
	add_child( ch )
	add_child( ch2, true )
	
	var result = SerializerGd.serializeTest(self)
	if not result.canSave():
		print("not canSave()")

	if result.getNotInstantiableNodes().size() != 2:
		print("result.getNotInstantiableNodes().size() != 2")

	var data = m_serializer.serialize( self )
	
	if data['CHILDREN'].size() != 2:
		print("data['CHILDREN'].size() != 2")

	if data['CHILDREN']['Node2D']['CHILDREN'].size() != 2:
		print("data['CHILDREN']['Node2D']['CHILDREN'].size() != 2")
	pass


var a = 24

func serialize():
	return {0 : a}


func deserialize( dict ):
	a = dict[0]
