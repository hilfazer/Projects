extends Node2D

var paths: Array[PackedVector2Array]


func _draw():
	for path in paths:
		for i in path.size() - 1:
			draw_line(path[i], path[i+1], Color.BROWN, 1.2)
