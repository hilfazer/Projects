extends Node

const SerializerGd = preload("res://Serializer.gd")
const Node2DScn = preload("res://test/Node2D.tscn")

const SaveFilename = "res://save/file.save"

var m_serializer = SerializerGd.new()


func _ready():
	call_deferred("deferredTest")
	
	
func deferredTest():
	m_serializer.saveBranch( $Parent.name, m_serializer.serialize( $Parent ) )
	m_serializer.saveBranch( $NoSceneNoSerialize.name, m_serializer.serialize( $NoSceneNoSerialize ) )
	m_serializer.saveToFile( SaveFilename )
	m_serializer.loadFromFile( SaveFilename )
	
	var savedNodes = m_serializer.getSavedNodes()
	if savedNodes.empty():
		print("could not load from file %s" % SaveFilename)
		return
	
	$Parent.free()
	$NoSceneNoSerialize.free()
	assert( !has_node("Parent") and !has_node("NoSceneNoSerialize") )
	
	m_serializer.deserialize(savedNodes, self)
	
	