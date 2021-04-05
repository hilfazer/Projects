extends "res://tests/GutTestBase.gd"

const PointsDataGd =         preload("res://new_builder/PointsData.gd")


enum CreateIdx { Step, Rect, Offset, Properties }
const PointsDataCreationParams = [
	[
		Vector2(30, 30),
		Rect2(-100,-200, 300, 200),
		Vector2(),
		[Vector2(-90, -180), 10, 6, Vector2(30, 30), Vector2()]
	],
	[
		Vector2(10, 20),
		Rect2(0, 70, 140, 200),
		Vector2(0, 10),
		[Vector2(0, 70), 14, 10, Vector2(10, 20), Vector2(0, 10)]
	],
	[
		Vector2(20, 20),
		Rect2(0, 0, 212, 212),
		Vector2(10, 10),
		[Vector2(10, 10), 11, 11, Vector2(20, 20), Vector2(10, 10)]
	],
]


func test_createPointsData( prm = use_parameters(PointsDataCreationParams) ):
	var pointsData := PointsDataGd.PointsData.create( \
		prm[CreateIdx.Step], prm[CreateIdx.Rect], prm[CreateIdx.Offset] )

	var targetProperties = prm[CreateIdx.Properties]
	assert_eq(pointsData.topLeftPoint, targetProperties[0])
	assert_eq(pointsData.xCount, targetProperties[1])
	assert_eq(pointsData.yCount, targetProperties[2])
	assert_eq(pointsData.step, targetProperties[3])
	assert_eq(pointsData.offset, targetProperties[4])

