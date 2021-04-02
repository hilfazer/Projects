extends "res://tests/GutTestBase.gd"

const AStarBuilderGd =       preload("res://CollisionAStarBuilder.gd")
const StaticFunctionsGd =    preload("res://CollisionAStarFunctions.gd")
const PointsDataGd =         preload("res://PointsData.gd")

const PointsData =           PointsDataGd.PointsData


func test_calculateIdsForPoints():
	var pointsData := PointsData.make( \
			Vector2(16,16), Rect2(50,50,150,200), Vector2(12,12) )

	var pointsToIds = StaticFunctionsGd.calculateIdsForPoints( pointsData, Rect2(10,20,300,300) )
	assert_typeof(pointsToIds, TYPE_DICTIONARY)
	assert_eq(pointsToIds.size(), 9*12)
	assert_has(pointsToIds, Vector2(124,140))
	assert_has(pointsToIds, Vector2(60,60))
	assert_does_not_have(pointsToIds, Vector2(220,268))

	var negative = false
	for id in pointsToIds.values():
		if id < 0:
			negative = true
			break
	assert_false(negative)


func test_createConnectionsStraight():
	var pointsData := PointsData.make( \
			Vector2(24, 32), Rect2(0, 0, 48, 64), Vector2(10, 20))

	var connections = StaticFunctionsGd.createConnections(pointsData, false)
	var connNum : int = 0
	connNum += pointsData.xCount * (pointsData.yCount - 1)
	connNum += pointsData.yCount * (pointsData.xCount - 1)
	assert_eq(connections.size(), connNum)
	assert_has(connections, [Vector2(10, 20), Vector2(34, 20)])
	assert_has(connections, [Vector2(10, 20), Vector2(10, 52)])
	assert_has(connections, [Vector2(34, 20), Vector2(34, 52)])
	assert_has(connections, [Vector2(10, 52), Vector2(34, 52)])
	assert_does_not_have(connections, [Vector2(-14, 20), Vector2(10, 20)])
	assert_does_not_have(connections, [Vector2(10, -12), Vector2(10, 20)])
	assert_does_not_have(connections, [Vector2(34, 52), Vector2(34, 84)])
	assert_does_not_have(connections, [Vector2(10, 20), Vector2(34, 52)])


func test_createConnectionsDiagonal():
	var pointsData := PointsData.make(Vector2(32, 32), Rect2(12, 36, 320, 320))
	var connections = StaticFunctionsGd.createConnections(pointsData, true)
	var connNum : int = 0
	connNum += pointsData.xCount * (pointsData.yCount - 1)
	connNum += pointsData.yCount * (pointsData.xCount - 1)
	connNum += (pointsData.xCount-1) * (pointsData.yCount-1) * 2
	assert_eq(connections.size(), connNum)
	assert_has(connections, [Vector2(128, 256), Vector2(160, 288)])
	assert_does_not_have(connections, [Vector2(32, 32), Vector2(64, 64)])


func test_createFullyConnectedAStar():
	var pointsHorizontal := 8
	var pointsVertical := 7

	var pointsData := PointsData.make( \
			Vector2(20, 30), Rect2(20, 30, 20 * pointsHorizontal, 30 * pointsVertical))
	var pts2ids := StaticFunctionsGd.calculateIdsForPoints( pointsData )
	var astar : AStar2D = StaticFunctionsGd.createFullyConnectedAStar( pointsData, pts2ids, false )

	assert_eq( astar.get_point_count(), pointsHorizontal * pointsVertical )
	assert_eq( astar.get_point_connections( pts2ids[Vector2(20,30)] ).size(), 2)
	assert_eq( astar.get_point_connections( pts2ids[Vector2(40,90)] ).size(), 4)
	assert_eq( astar.get_point_connections( pts2ids[Vector2(20,90)] ).size(), 3)
	assert_eq( astar.get_point_connections( pts2ids[Vector2(160,210)] ).size(), 2)

	var astarDiagonal : AStar2D = StaticFunctionsGd.createFullyConnectedAStar( \
			pointsData, pts2ids, true )

	assert_eq( astarDiagonal.get_point_count(), pointsHorizontal * pointsVertical )
	assert_eq( astarDiagonal.get_point_connections( pts2ids[Vector2(20,30)] ).size(), 3)
	assert_eq( astarDiagonal.get_point_connections( pts2ids[Vector2(40,90)] ).size(), 8)
	assert_eq( astarDiagonal.get_point_connections( pts2ids[Vector2(100,30)] ).size(), 5)
	assert_eq( astarDiagonal.get_point_connections( pts2ids[Vector2(160,210)] ).size(), 3)


func test_pointsFromRect():
	var pointsData := PointsData.make(
			Vector2(20, 20), Rect2(0, 0, 212, 212), Vector2(10, 10))
	var rect := Rect2(65, 65, 65, 65)
	var points := StaticFunctionsGd.pointsFromRect( rect, pointsData )

	assert_eq( points.size(), 9 )
	assert_has( points, Vector2(90, 90) )
	assert_has( points, Vector2(70, 110) )
	assert_does_not_have( points, Vector2(130, 130) )
	assert_does_not_have( points, Vector2(20, 20) )


func test_pointsFromRectangles():
	var pointsData := PointsData.make(
			Vector2(20, 20), Rect2(0, 0, 212, 212), Vector2(10, 10))
	var rect1 := Rect2(65, 65, 65, 65)
	var rect2 := Rect2(-50, 0, 80, 66)
	var arr = [rect1, rect2]
	var points := StaticFunctionsGd.pointsFromRectangles( arr, pointsData )

	assert_eq(points.size(), 9 + 3)

