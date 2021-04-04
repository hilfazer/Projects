extends "res://tests/GutTestBase.gd"

const GraphGd =       preload("res://new_builder/CollisionAStarGraph.gd")
const FunctionsGd =   preload("res://new_builder/CollisionAStarFunctions.gd")
const PointsDataGd =  preload("res://new_builder/PointsData.gd")

var pointsData := PointsDataGd.PointsData.create( \
		Vector2(10, 15), Rect2(0, 0, 200, 165))
var pts2ids := FunctionsGd.calculateIdsForPoints( pointsData )
var astar : AStar2D = FunctionsGd.createFullyConnectedAStar( \
		pointsData, pts2ids, true )


func test_createGraph():
	var shape := RectangleShape2D.new()
	shape.extents = Vector2(20, 20)
	var mask := 1
	var graph : GraphGd = autofree( GraphGd.new(astar, shape, mask) )

	assert_not_null(graph.astar2d)


func test__createAndSetupProbe():
	var shape := RectangleShape2D.new()
	shape.extents = Vector2(20, 20)
	var mask := 1
	var probe : PhysicsBody2D = autofree(GraphGd._createAndSetupProbe(shape, mask))

	assert_eq(probe.collision_mask, mask)
