tool
extends "res://AbstractTypeLine.gd"


var objects := []


func _create( count : int ) -> int:
	objects.resize(count)
	for i in objects.size():
		objects[i] = MyRes.new()
	return OK


func _destroy():
	objects.clear()


func _compute():
	var _sum := 0
	for ob in objects:
		_sum = ob.get_instance_id()



class MyRes extends Resource:
	pass
