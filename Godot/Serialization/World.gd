extends Node

const SerializerGd = preload("res://Serializer.gd")
const Node2DScn = preload("res://Node2D.tscn")

var m_serializer = SerializerGd.new()


func _ready():
#	var data1 = m_serializer.serialize( $Parent )
	call_deferred("populate")
	call_deferred("savePackedScene")
	call_deferred("saveSerializedTree")
	call_deferred("saveSerializedFlat")
	pass


func populate():
	for i in range(0,300):
		var n = Node2DScn.instance()
		add_child(n)
		n.owner = self
	
	
func savePackedScene():
	var scene = PackedScene.new()
	var result = scene.pack(self)
	if result == OK:
		ResourceSaver.save("res://save/savedPacked.scn", scene)
		pass
	
	
func saveSerializedTree():
	var data = m_serializer.serialize( self )
	
	var saveFile = File.new()

	if OK != saveFile.open("res://save/savedTree.json", File.WRITE):
		return
		
	saveFile.store_line(to_json(data))

	saveFile.close()
	
	
func saveSerializedFlat():
	pass


func serialize():
	return {
		"SCENE" : filename,
		"CHILDREN" : { }
	}
