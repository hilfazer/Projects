extends "res://tests/GutTestBase.gd"

const GraphGd =              preload("res://new_builder/CollisionGraph.gd")
const FunctionsGd =          preload("res://new_builder/StaticFunctions.gd")
const PointsDataGd =         preload("res://new_builder/PointsData.gd")
const TestingFunctionsGd =   preload("./files/TestingFunctions.gd")


var pointsData := PointsDataGd.PointsData.create(
		Vector2(10, 15), Rect2(0, 0, 200, 165))
var pts2ids := FunctionsGd.calculateIdsForPoints(pointsData)


class Test_makeNeighbourOffsets extends "res://tests/GutTestBase.gd":
	enum Idx {Step, Diagonal, Points}
	const Params = [
		[
			Vector2(7, 12),
			false,
			[Vector2(7, 0), Vector2(0, 12)]
		],
		[
			Vector2(8, 3),
			true,
			[Vector2(8, 0), Vector2(0, 3), Vector2(8, 3), Vector2(8, -3)]
		],
	]


	func test_makeNeighbourOffsets(prm = use_parameters(Params)):
		var offsets = GraphGd.makeNeighbourOffsets(prm[Idx.Step], prm[Idx.Diagonal])
		offsets.sort()
		var toCompare = prm[Idx.Points]
		toCompare.sort()
		assert_eq_shallow(toCompare, offsets)


func test_createGraph():
	var neighbourOffsets := GraphGd.makeNeighbourOffsets(pointsData.step, true)
	var graph : GraphGd = autofree( GraphGd.new(pointsData, pts2ids, neighbourOffsets) )

	assert_not_null(graph.astar2d)
	var astar = graph.astar2d
	assert_eq(astar.get_point_count(), pointsData.xCount * pointsData.yCount)


func test_initializeProbe():
	var shape := RectangleShape2D.new()
	shape.extents = Vector2(20, 20)
	var mask = 1
	var neighbourOffsets := GraphGd.makeNeighbourOffsets(pointsData.step, true)
	var graph : GraphGd = autofree( GraphGd.new(pointsData, pts2ids, neighbourOffsets) )
	graph.initializeProbe(shape, mask)

	assert_eq(graph._probe.collision_mask, mask)
	assert_eq(graph._probe.get_node("CollisionShape2D").shape.extents, Vector2(20, 20))
	assert_not_null(graph._shapeParams)


func test_updateGraph():
	var viewport :Viewport = add_child_autofree( Viewport.new() )

	var neighbourOffsets := GraphGd.makeNeighbourOffsets(pointsData.step, true)
	var graph :GraphGd = GraphGd.new(pointsData, pts2ids, neighbourOffsets)
	viewport.add_child(graph)

	var shape := RectangleShape2D.new()
	shape.extents = Vector2(16, 32)
	var mask = 1
	graph.initializeProbe(shape, mask)

	var points = FunctionsGd.pointsFromRect(pointsData.boundingRect, pointsData)
	graph.updateGraph(points)

	var hasAnyDisabled = false
	for pointID in graph.astar2d.get_points():
		if graph.astar2d.is_point_disabled(pointID):
			hasAnyDisabled = true
			break
	assert_false(hasAnyDisabled)


func test_findEnabledAndDisabledConnections():
	var pointsData2 := PointsDataGd.PointsData.create(
			Vector2(20, 20), Rect2(0, 0, 80, 80))
	var pts2ids2 := FunctionsGd.calculateIdsForPoints( pointsData2 )

	var viewport :Viewport = add_child_autofree( Viewport.new() )

	var neighbourOffsets := GraphGd.makeNeighbourOffsets(pointsData2.step, true)
	var graph :GraphGd = GraphGd.new(pointsData2, pts2ids2, neighbourOffsets)
	viewport.add_child(graph)

	var shape := RectangleShape2D.new()
	shape.extents = Vector2(9, 9)
	var mask = 1
	graph.initializeProbe(shape, mask)

	var points = FunctionsGd.pointsFromRect(pointsData2.boundingRect, pointsData2)
	var fullConnectionCount = TestingFunctionsGd.calculateEdgeCountInRect(
			pointsData2.xCount, pointsData2.yCount, true)

	var ED_connections = GraphGd.findEnabledAndDisabledConnections(
		points, [], graph._probe,
		graph._shapeParams, neighbourOffsets, pointsData2.boundingRect
		)
	assert_eq(ED_connections[0].size(), fullConnectionCount)
	assert_eq(ED_connections[1].size(), 0)

	ED_connections = GraphGd.findEnabledAndDisabledConnections(
		points, [Vector2(40, 40)], graph._probe,
		graph._shapeParams, neighbourOffsets, pointsData2.boundingRect
		)
	assert_between(ED_connections[0].size(), fullConnectionCount - 8, fullConnectionCount)
	assert_between(ED_connections[1].size(), 0, 8)


func test_calculateEdgeCountInRect():
	var edgesNoDiagonal = TestingFunctionsGd.calculateEdgeCountInRect(5, 6, false)
	assert_eq(49, edgesNoDiagonal)
	var edgesDiagonal = TestingFunctionsGd.calculateEdgeCountInRect(4, 4, true)
	assert_eq(42, edgesDiagonal)

