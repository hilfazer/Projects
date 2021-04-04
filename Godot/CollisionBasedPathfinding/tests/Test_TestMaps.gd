extends "res://tests/GutTestBase.gd"


const AStarBuilderGd =       preload("res://new_builder/CollisionAStarBuilder.gd")
const TestMap1Scn =          preload("res://tests/files/TestMap1.tscn")


func test_calculateRectFromTilemaps():
	var map = autofree(TestMap1Scn.instance())
	var step := Vector2(0, 0)
	assert(map is TileMap)
	var boundingRect : Rect2 = AStarBuilderGd.calculateRectFromTilemaps([map], step)

	assert_eq(boundingRect, Rect2(96, 96, 129, 129))


func test_map1NoOffsetNoDiagonal():
	var map : TileMap = autofree(TestMap1Scn.instance())
	var step := map.cell_size
	assert(map is TileMap)
	var boundingRect : Rect2 = AStarBuilderGd.calculateRectFromTilemaps([map], step)
	var rectShape : RectangleShape2D = map.get_node("Unit/CollisionShape2D").shape
	var mask : int = map.get_node("Unit").collision_mask

	var builder := AStarBuilderGd.new()
	map.add_child(builder)
	builder.initialize(step, boundingRect, Vector2(), false)

	var graphId = builder.createGraph(rectShape, mask)
	assert_gt(graphId, 0)

	var astar : AStar2D = builder.getAStar2D(graphId)
	assert_eq(astar.get_point_count(), 25)
	assert_eq(_getEnabledPoints(astar).size(), 9)


func test_map1OffsetNoDiagonal():
	var map = autofree(TestMap1Scn.instance())
	var step := Vector2(32, 32)
	assert(map is TileMap)
	var boundingRect : Rect2 = AStarBuilderGd.calculateRectFromTilemaps([map], step)
	var rectShape : RectangleShape2D = map.get_node("Unit/CollisionShape2D").shape
	var mask : int = map.get_node("Unit").collision_mask

	var builder := AStarBuilderGd.new()
	map.add_child(builder)
	builder.initialize(step, boundingRect, Vector2(16, 16), false)

	var graphId = builder.createGraph(rectShape, mask)
	assert_gt(graphId, 0)

	var astar : AStar2D = builder.getAStar2D(graphId)
	assert_eq(astar.get_point_count(), 16)
	assert_eq(_getEnabledPoints(astar).size(), 12)


func _getEnabledPoints(astar : AStar2D) -> PoolIntArray:
	var enabledPoints := PoolIntArray()
	for point in astar.get_points():
		if not astar.is_point_disabled(point):
			enabledPoints.append(point)
	return enabledPoints
