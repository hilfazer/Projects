extends "res://tests/GutTestBase.gd"

const GraphGd =              preload("res://new_builder/CollisionAStarGraph.gd")
const AStarBuilderGd =       preload("res://new_builder/CollisionAStarBuilder.gd")
const TestMap1Scn =          preload("res://tests/files/TestMap1.tscn")
const PointsDataGd =  preload("res://new_builder/PointsData.gd")
const FunctionsGd =   preload("res://new_builder/CollisionAStarFunctions.gd")


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
	var ret = builder.initialize(step, boundingRect, Vector2(), false)
	assert_eq(ret, OK)


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
	var ret = builder.initialize(step, boundingRect, Vector2(16, 16), false)
	assert_eq(ret, OK)

	var graphId = builder.createGraph(rectShape, mask)
	assert_gt(graphId, 0)

	var astar : AStar2D = builder.getAStar2D(graphId)
	assert_eq(astar.get_point_count(), 16)
	assert_eq(_getEnabledPoints(astar).size(), 12)


func test_findEnabledAndDisabledPointsMap1():
	var viewport : Viewport = autofree( Viewport.new() )
	call_deferred('add_child', viewport)
	yield(viewport, 'ready')

	var map = TestMap1Scn.instance()
	var step := Vector2(32, 32)
	assert(map is TileMap)
	var boundingRect : Rect2 = AStarBuilderGd.calculateRectFromTilemaps([map], step)
	var rectShape : RectangleShape2D = map.get_node("Unit/CollisionShape2D").shape
	var mask : int = map.get_node("Unit").collision_mask
	viewport.add_child(map)

	var pointsData := PointsDataGd.PointsData.create(step, boundingRect)
	var pts2ids := FunctionsGd.calculateIdsForPoints(pointsData)

	var neighbourOffsets := GraphGd.makeNeighbourOffsets(pointsData.step, true)
	var graph :GraphGd = GraphGd.new(pointsData, pts2ids, neighbourOffsets)
	viewport.add_child(graph)

	graph.initializeProbe(rectShape, mask)

	var points = FunctionsGd.pointsFromRect(pointsData.boundingRect, pointsData)
	var EDpoints = GraphGd.findEnabledAndDisabledPoints(points, graph._probe, graph._shapeParams)

	var enabled = EDpoints[0]
	var enabledToCompare = [Vector2(160,96),Vector2(160,128),Vector2(160,160),
			Vector2(96,160),Vector2(128,160),Vector2(192,160),Vector2(224,160),
			Vector2(224,192),Vector2(224,224)]
	enabled.sort()
	enabledToCompare.sort()
	assert_eq_shallow(enabled, enabledToCompare)

	var disabled = EDpoints[1]
	var disabledToCompare = [
			Vector2(96,128),Vector2(128,96),Vector2(96,96),Vector2(128,128),
			Vector2(192,96),Vector2(224,96),Vector2(192,128),Vector2(224,128),
			Vector2(96,192),Vector2(128,192),Vector2(160,192),Vector2(192,192),
			Vector2(96,224),Vector2(128,224),Vector2(160,224),Vector2(192,224),
			]
	disabled.sort()
	disabledToCompare.sort()
	assert_eq_shallow(disabled, disabledToCompare)


static func _getEnabledPoints(astar : AStar2D) -> PoolIntArray:
	var enabledPoints := PoolIntArray()
	for point in astar.get_points():
		if not astar.is_point_disabled(point):
			enabledPoints.append(point)
	return enabledPoints
