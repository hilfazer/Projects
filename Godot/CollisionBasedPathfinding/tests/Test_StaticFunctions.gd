extends "res://tests/GutTestBase.gd"

const AStarBuilderGd = preload("res://CollisionAStarBuilder.gd")

enum CreationIndex { Step, Rect, Offset, Properties }
var pointsDataCreationParams = [
	[Vector2(30, 30), Rect2(-100,-200, 300, 200), Vector2(), \
		[Vector2(-90, -180), 10, 6, Vector2(30, 30), Vector2()] ],

	[Vector2(10, 20), Rect2(0, 70, 140, 200), Vector2(0, 10), \
		[Vector2(0, 70), 14, 10, Vector2(10, 20), Vector2(0, 10)] ],
]


func test_makePointsData( params = use_parameters(pointsDataCreationParams) ):
	var pointsData : AStarBuilderGd.PointsData = AStarBuilderGd.makePointsData( \
		params[CreationIndex.Step], params[CreationIndex.Rect], params[CreationIndex.Offset] )

	var targetProperties = params[CreationIndex.Properties]
	assert_eq(pointsData.topLeftPoint, targetProperties[0])
	assert_eq(pointsData.xCount, targetProperties[1])
	assert_eq(pointsData.yCount, targetProperties[2])
	assert_eq(pointsData.step, targetProperties[3])
	assert_eq(pointsData.offset, targetProperties[4])


func test_calculateIdsForPoints():
	var pointsData : AStarBuilderGd.PointsData = AStarBuilderGd.makePointsData( \
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
	var pointsData := AStarBuilderGd.PointsData.new()
	pointsData.topLeftPoint = Vector2(10,20)
	pointsData.xCount = 2
	pointsData.yCount = 2
	pointsData.step = Vector2(24,32)
	pointsData.boundingRect = Rect2(20, 20, pointsData.xCount*32, pointsData.yCount*32)

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
	var pointsData := AStarBuilderGd.PointsData.new()
	pointsData.topLeftPoint = Vector2(12,36)
	pointsData.xCount = 100
	pointsData.yCount = 100
	pointsData.step = Vector2(32,32)
	pointsData.boundingRect = Rect2(12, 36, pointsData.xCount*32, pointsData.yCount*32)

	var connections = AStarBuilderGd.createConnections(pointsData, true)
	var connNum : int = 0
	connNum += pointsData.xCount * (pointsData.yCount - 1)
	connNum += pointsData.yCount * (pointsData.xCount - 1)
	connNum += (pointsData.xCount-1) * (pointsData.yCount-1) * 2
	assert_eq(connections.size(), connNum)


func test_makeAStarPrototype():
	pending()
