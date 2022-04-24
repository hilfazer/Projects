extends Node

const res_writer = preload("res://resource_sharing/resource_writer.gd")
const res_reader = preload("res://resource_sharing/resource_reader.gd")

func _ready():
	var writer = res_writer.new()

	writer.preload_and_write()
	call_deferred("read_with_preload")

	writer.load_and_write()
	call_deferred("read_with_load")


func read_with_preload():
	var reader = res_reader.new()
	reader.preload_and_read()


func read_with_load():
	var reader = res_reader.new()
	reader.load_and_read()


func _on_ChangeScene_pressed():
	get_tree().change_scene("res://resource_sharing/IntermediateScene.tscn")

