tool
extends Area2D


func _process(_delta):
	var rectShape : RectangleShape2D = $"CollisionShape2D".shape
	var x = rectShape.extents.x
	var y = rectShape.extents.y
	var points = $"Perimeter".points

	assert(points.size() == 5)
	points[0] = Vector2(-x, -y)
	points[1] = Vector2(-x, y)
	points[2] = Vector2(x, y)
	points[3] = Vector2(x, -y)
	points[4] = points[0]
	$"Perimeter".points = points
