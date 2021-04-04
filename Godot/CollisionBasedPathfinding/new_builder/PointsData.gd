extends Reference


class PointsData:
# warning-ignore:unused_class_variable
	var topLeftPoint : Vector2
# warning-ignore:unused_class_variable
	var xCount : int
# warning-ignore:unused_class_variable
	var yCount : int
# warning-ignore:unused_class_variable
	var step : Vector2
# warning-ignore:unused_class_variable
	var offset : Vector2
# warning-ignore:unused_class_variable
	var boundingRect : Rect2

	static func create( step_ : Vector2, rect : Rect2, offset_ : Vector2 = Vector2() ) -> PointsData:
		assert(offset_.x >= 0)
		assert(offset_.y >= 0)

		var data = PointsData.new()

		var topLeft = (rect.position).snapped(step_)
		topLeft += offset_
		topLeft.x = topLeft.x if topLeft.x >= rect.position.x else topLeft.x + step_.x
		topLeft.y = topLeft.y if topLeft.y >= rect.position.y else topLeft.y + step_.y
		if topLeft.x - step_.x >= rect.position.x:
			topLeft.x -= step_.x
		if topLeft.y - step_.y >= rect.position.y:
			topLeft.y -= step_.y
		data.topLeftPoint = topLeft

		var xFirstToRectEnd = (rect.position.x + rect.size.x -1) - data.topLeftPoint.x
		data.xCount = int(xFirstToRectEnd / step_.x) + 1

		var yFirstToRectEnd = (rect.position.y + rect.size.y -1) - data.topLeftPoint.y
		data.yCount = int(yFirstToRectEnd / step_.y) + 1

		data.offset = offset_
		data.step = step_
		data.boundingRect = rect
		return data
