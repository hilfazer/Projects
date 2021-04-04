extends "res://tests/GutTestBase.gd"

const GraphGd =       preload("res://CollisionAStarGraph.gd")
const FunctionsGd =   preload("res://CollisionAStarFunctions.gd")
const PointsDataGd =  preload("res://PointsData.gd")

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


	pending()


func test__createAndSetupTester():
	var shape := RectangleShape2D.new()
	shape.extents = Vector2(20, 20)
	var mask := 1
	var tester : PhysicsBody2D = autofree(GraphGd._createAndSetupTester(shape, mask))

	assert_eq(tester.collision_mask, mask)
	pending()
