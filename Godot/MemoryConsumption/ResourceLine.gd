extends "res://AbstractTypeLine.gd"


var objects := []


func _create( count : int ) -> int:
	objects.resize(count)
	for i in objects.size():
		objects[i] = Resource.new()
	return OK


func _destroy():
	objects.resize(0)


func _compute():
	var sum := 0
	for ob in objects:
		sum = ob.get_instance_id()

