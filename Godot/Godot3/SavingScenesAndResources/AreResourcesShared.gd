extends Node

const AResource = preload("res://a_resource.gd")


func _ready():
	var r1 = AResource.new()
	var r2 = AResource.new()
	r1.pp = 5
	print("shared") if r1.pp == r2.pp else print("not shared")
