extends "res://tests/GutTestBase.gd"

const AStarBuilderGd = preload("res://CollisionAStarBuilder.gd")

enum CreationIndex { Step, Rect, Offset, Properties }
var pointsDataCreationParams = [
	[Vector2(30, 30), Rect2(-100,-200, 300, 200), Vector2(), \
		[Vector2(-90, -180), 10, 6, Vector2(30, 30), Vector2()] ],

	[Vector2(10, 20), Rect2(0, 70, 140, 200), Vector2(0, 10), \
		[Vector2(0, 70), 14, 10, Vector2(10, 20), Vector2(0, 10)] ],

	[Vector2(20, 20), Rect2(0, 0, 212, 212), Vector2(10, 10), \
		[Vector2(10, 10), 11, 11, Vector2(20, 20), Vector2(10, 10)] ],
]


func test_PointsDataMake( params = use_parameters(pointsDataCreationParams) ):
	var pointsData := AStarBuilderGd.PointsData.make( \
		params[CreationIndex.Step], params[CreationIndex.Rect], params[CreationIndex.Offset] )

	var targetProperties = params[CreationIndex.Properties]
	assert_eq(pointsData.topLeftPoint, targetProperties[0])
	assert_eq(pointsData.xCount, targetProperties[1])
	assert_eq(pointsData.yCount, targetProperties[2])
	assert_eq(pointsData.step, targetProperties[3])
	assert_eq(pointsData.offset, targetProperties[4])


func test_calculateIdsForPoints():
	var pointsData := AStarBuilderGd.PointsData.make( \
			Vector2(16,16), Rect2(50,50,150,200), Vector2(12,12) )

	var pointsToIds = AStarBuilderGd.calculateIdsForPoints( pointsData, Rect2(10,20,300,300) )
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
	var pointsData := AStarBuilderGd.PointsData.make( \
			Vector2(24, 32), Rect2(0, 0, 48, 64), Vector2(10, 20))

	var connections = AStarBuilderGd.createConnections(pointsData, false)
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
	var pointsData := AStarBuilderGd.PointsData.make(Vector2(32, 32), Rect2(12, 36, 320, 320))
	var connections = AStarBuilderGd.createConnections(pointsData, true)
	var connNum : int = 0
	connNum += pointsData.xCount * (pointsData.yCount - 1)
	connNum += pointsData.yCount * (pointsData.xCount - 1)
	connNum += (pointsData.xCount-1) * (pointsData.yCount-1) * 2
	assert_eq(connections.size(), connNum)
	assert_has(connections, [Vector2(128, 256), Vector2(160, 288)])
	assert_does_not_have(connections, [Vector2(32, 32), Vector2(64, 64)])


func test_createFullyConnectedAStar():
	var pointsData := AStarBuilderGd.PointsData.make(Vector2(20, 30), Rect2(20, 30, 160, 210))
	var pts2ids := AStarBuilderGd.calculateIdsForPoints( pointsData )
	var astar : AStar2D = AStarBuilderGd.createFullyConnectedAStar( pointsData, pts2ids, false )

	assert_eq( astar.get_points().size(), 56 )


func test_pointsFromRect():
	var pointsData := AStarBuilderGd.PointsData.make(
			Vector2(20, 20), Rect2(0, 0, 212, 212), Vector2(10, 10))
	var rect := Rect2(65, 65, 65, 65)
	var points := AStarBuilderGd._pointsFromRect( rect, pointsData )

	assert_eq( points.size(), 9 )
	assert_has( points, Vector2(90, 90) )
	assert_has( points, Vector2(70, 110) )
	assert_does_not_have( points, Vector2(130, 130) )
	assert_does_not_have( points, Vector2(20, 20) )


func test_pointsFromRectangles():
	var pointsData := AStarBuilderGd.PointsData.make(
			Vector2(20, 20), Rect2(0, 0, 212, 212), Vector2(10, 10))
	var rect1 := Rect2(65, 65, 65, 65)
	var rect2 := Rect2(-50, 0, 80, 66)
	var arr = [rect1, rect2]
	var points := AStarBuilderGd._pointsFromRectangles( arr, pointsData )

	assert_eq(points.size(), 9 + 3)



