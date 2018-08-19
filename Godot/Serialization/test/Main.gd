extends Node

const SerializerGd = preload("res://Serializer.gd")
const Node2DScn = preload("res://test/Node2D.tscn")
const ParentScn = preload("res://test/Parent.tscn")

const SaveFilename = "res://save/file.save"

const tests = [
	"res://test/Test1.tscn",
	"res://test/Test2.tscn",
	"res://test/Test3.tscn",
	"res://test/Test4.tscn",
	"res://test/Test5.tscn",
]


func _ready():
	call_deferred("test")
	
	
func test():
	for testScene in tests:
		var test = load(testScene).instance()
		print("Starting test %s" % testScene)
		add_child(test)
		test.free()
	
	pass

