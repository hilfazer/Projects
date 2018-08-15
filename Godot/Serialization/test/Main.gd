extends Node

const SerializerGd = preload("res://Serializer.gd")
const Node2DScn = preload("res://test/Node2D.tscn")
const ParentScn = preload("res://test/Parent.tscn")

const SaveFilename = "res://save/file.save"



func _ready():
	call_deferred("test")
	
	
func test():
	var test1 = preload("res://test/Test1.tscn").instance()
	add_child(test1)
	test1.free()
	
	var test2 = preload("res://test/Test2.tscn").instance()
	add_child(test2)
	test2.free()
	
	pass
	
	
#func test_():
#	m_serializer.saveBranch( $Parent.name, m_serializer.serialize( $Parent ) )
#	m_serializer.saveBranch( $NoSceneNoSerialize.name, m_serializer.serialize( $NoSceneNoSerialize ) )
#	m_serializer.saveToFile( SaveFilename )
#	m_serializer.loadFromFile( SaveFilename )
#
#	var savedNodes = m_serializer.getSavedNodes()
#	if savedNodes.empty():
#		print("could not load from file %s" % SaveFilename)
#		return
#
#	$Parent.free()
#	$NoSceneNoSerialize.free()
#	assert( !has_node("Parent") and !has_node("NoSceneNoSerialize") )
#
#	m_serializer.deserialize(savedNodes, self)
	
	