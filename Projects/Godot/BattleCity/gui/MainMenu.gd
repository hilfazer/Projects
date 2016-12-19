
extends Node2D


func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	OS.set_window_size(Vector2(1024,768))
	get_tree().change_scene( "res://stages/Stage1.tscn" )


func _on_Node_enter_tree():
	VisualServer.set_default_clear_color(Color(0,0,0,0))
