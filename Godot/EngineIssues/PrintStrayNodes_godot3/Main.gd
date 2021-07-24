extends Node

const BananaGd = preload("res://Banana.gd")
const GrapesGd = preload("res://Grapes.gd")


func _ready():
	var node = Node.new()
	node.set_script(BananaGd)
	node = GrapesGd.new()
	var parent = Node2D.new()
	parent.add_child(node)

	call_deferred("print_stray")


func print_stray():
	print_stray_nodes()
	pass
