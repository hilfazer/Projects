extends Node

var _step : Vector2
var _boundingRect : Rect2
var _pointsData : PointsData


func initialize( step : Vector2, boundingRect : Rect2 ):
	_step = step
	_boundingRect = boundingRect
	_pointsData = _pointsDataFromRect( step, boundingRect )


func getBoundingRect() -> Rect2:
	return _boundingRect


func getPointsData() -> PointsData:
	return _pointsData


func _pointsDataFromRect( step : Vector2, rect : Rect2 ) -> PointsData:
	var data = PointsData.new()

	data.topLeftPoint.x = stepify(rect.position.x + step.x/2, step.x)
	var xLastPoint : int = int((rect.position.x + rect.size.x -1) / step.x) * int(step.x)
	data.xCount = int((xLastPoint - data.topLeftPoint.x) / 16) + 1

	data.topLeftPoint.y = stepify(rect.position.y + step.y/2, step.y)
	var yLastPoint : int = int((rect.position.y + rect.size.y -1) / step.y) * int(step.y)
	data.yCount = int((yLastPoint - data.topLeftPoint.y) / 16) + 1

	return data


class PointsData:
	var topLeftPoint : Vector2
	var xCount : int
	var yCount : int
