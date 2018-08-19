extends Node

const SerializerGd = preload("res://Serializer.gd")
const Node2DScn = preload("res://test/Node2D.tscn")
const ParentScn = preload("res://test/Parent.tscn")

const SaveFilename = "res://save/file.save"

const tests = [
	"res://test/Test1.tscn",
	"res://test/Test2.tscn"
]


func _ready():
	call_deferred("test")
	
	
func test():
	for testScene in tests:
		var test = load(testScene).instance()
		add_child(test)
		test.free()
	
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
	
	