extends "res://tests/GutTestBase.gd"

const GraphGd =       preload("res://new_builder/CollisionAStarGraph.gd")
const FunctionsGd =   preload("res://new_builder/CollisionAStarFunctions.gd")
const PointsDataGd =  preload("res://new_builder/PointsData.gd")

var pointsData := PointsDataGd.PointsData.create( \
		Vector2(10, 15), Rect2(0, 0, 200, 165))
var pts2ids := FunctionsGd.calculateIdsForPoints( pointsData )


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


	func test_makeNeighbourOffsets( prm = use_parameters(Params) ):
		var offsets = GraphGd.makeNeighbourOffsets(prm[Idx.Step], prm[Idx.Diagonal])
		for pt in prm[Idx.Points]:
			assert_has(offsets, pt)


#func test_createGraph():
#	var graph : GraphGd = autofree( GraphGd.new(pointsData, pts2ids, []) )
#
#	assert_not_null(graph.astar2d)
#	var astar = graph.astar2d
#	assert_eq(astar.get_point_count(), pointsData.xCount * pointsData.yCount)
#
#
#func test_initializeProbe():
#	var shape := RectangleShape2D.new()
#	shape.extents = Vector2(20, 20)
#	var mask := 1
#	var graph : GraphGd = autofree( GraphGd.new(pointsData, pts2ids, []) )
#	graph.initializeProbe(shape, mask)
#
#	assert_eq(graph._probe.collision_mask, mask)
#	assert_eq(graph._probe.get_node("CollisionShape2D").shape.extents, Vector2(20, 20))



#func test_updateGraph():
#	var pointsData := PointsDataGd.PointsData.create( \
#		Vector2(32, 64), Rect2(0, 0, 200, 300), Vector2(16, 32) )
#	var shape := RectangleShape2D.new()
#	shape.extents = Vector2(16, 32)
#	var mask := 1
#	var graph = autofree(GraphGd.new(astar, shape, mask))
#
#	pending()
