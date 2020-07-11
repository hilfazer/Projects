extends Node

const CollisionAStarBuilderGd = preload("res://CollisionAStarBuilder.gd")

export(bool) var runAddPoint
export(bool) var runConnectionsAfterPoints
export(bool) var runPointsWithConnections
export(bool) var runCreateConnections
#export(bool) var runAddPoint


func _ready():
	if runAddPoint:
		testAddPoint()

	if runConnectionsAfterPoints:
		testConnectionsAfterPoints()

	if runPointsWithConnections:
		testPointsWithConnections()

	if runCreateConnections:
		testCreateConnections()


func testAddPoint():
	print('testAddPoint')
	var astar = AStar.new()
	print( str(_addPoint( Vector2(151, 113), astar ) ) + "ms" )


static func _addPoint( size : Vector2, astar : AStar ) -> int:
	var idsToPoints2d := {}
	for x in range(size.x):
		for y in range(size.y):
			var xx = (x+1) * 32
			var yy = (y+1) * 32
			var pointId = int(xx * size.x + yy)
			idsToPoints2d[pointId] = Vector2(xx, yy)

	var startTime := OS.get_system_time_msecs()

	for id in idsToPoints2d:
			astar.add_point( id , Vector3(idsToPoints2d[id].x, idsToPoints2d[id].y, 0.0) )

	return OS.get_system_time_msecs() - startTime


func testConnectionsAfterPoints():
	var astar
	print('testConnectionsAfterPoints')
	astar = AStar.new()
	print( str(_addConnectionsAfterPoints( Vector2(200, 200), astar ) ) + "ms" )
	astar = AStar.new()
	print( str(_addConnectionsAfterPoints( Vector2(200, 200), astar ) ) + "ms" )
	astar = AStar.new()
	print( str(_addConnectionsAfterPoints( Vector2(200, 200), astar ) ) + "ms" )


static func _addConnectionsAfterPoints( size : Vector2, astar : AStar ) -> int:
	var idsToCoords := {}
	var connections := []

	for x in range(size.x):
		for y in range(size.y):
			var pointId = (x * size.x + y)
			idsToCoords[pointId] = Vector3(x, y, 0.0)

	for x in range(size.x):
		for y in range(size.y):
			var idA = ((x+1) * size.x + y)
			if idsToCoords.has( idA ):
				connections.append(Vector2( (x * size.x + y), idA) )

			var idB = ((x+1) * size.x + (y-1))
			if idsToCoords.has( idB ):
				connections.append(Vector2( (x * size.x + y), idB) )

			var idC = ((x+1) * size.x + (y+1))
			if idsToCoords.has( idC ):
				connections.append(Vector2( (x * size.x + y), idC) )

			var idD = (x * size.x + (y+1))
			if idsToCoords.has( idD ):
				connections.append(Vector2( (x * size.x + y), idD) )

	var startTime := OS.get_system_time_msecs()

	for id in idsToCoords:
			astar.add_point( id , idsToCoords[id] )

	for idPair in connections:
		astar.connect_points(idPair[0], idPair[1])

	return OS.get_system_time_msecs() - startTime


func testPointsWithConnections():
	var astar
	print('testPointsWithConnections')
	astar = AStar.new()
	print( str(_addPointsWithConnections( Vector2(200, 200), astar ) ) + "ms" )
	astar = AStar.new()
	print( str(_addPointsWithConnections( Vector2(200, 200), astar ) ) + "ms" )
	astar = AStar.new()
	print( str(_addPointsWithConnections( Vector2(200, 200), astar ) ) + "ms" )


static func _addPointsWithConnections( size : Vector2, astar : AStar ) -> int:
	var pointIdsWithConnections = {}
	var idsToCoords = {}

	for x in range(size.x):
		for y in range(size.y):
			var pointId = (x * size.x + y)

			idsToCoords[pointId] = Vector3(x, y, 0.0)
			pointIdsWithConnections[pointId] = []

	for x in range(size.x):
		for y in range(size.y):
			var pointConnections := []

			var idA = ((x+1) * size.x + y)
			if pointIdsWithConnections.has( idA ):
				pointConnections.append(idA)

			var idB = ((x+1) * size.x + (y-1))
			if pointIdsWithConnections.has( idB ):
				pointConnections.append(idB)

			var idC = ((x+1) * size.x + (y+1))
			if pointIdsWithConnections.has( idC ):
				pointConnections.append(idC)

			var idD = (x * size.x + (y+1))
			if pointIdsWithConnections.has( idD ):
				pointConnections.append(idD)

			pointIdsWithConnections[(x * size.x + y)] = pointConnections

	var startTime := OS.get_system_time_msecs()

	for id in pointIdsWithConnections:
		astar.add_point(id, idsToCoords[id])

		for connectId in pointIdsWithConnections[id]:
			astar.add_point(connectId, idsToCoords[connectId])
			astar.connect_points(id, connectId)

	return OS.get_system_time_msecs() - startTime


func testCreateConnections():
	print('testCreateConnections')
	var pointsData := CollisionAStarBuilderGd.PointsData.new()
	pointsData.topLeftPoint = Vector2(20,20)
	pointsData.xCount = 400
	pointsData.yCount = 400
	pointsData.step = Vector2(32,32)
	pointsData.boundingRect = Rect2(20, 20, pointsData.xCount*32, pointsData.yCount*32)

	var neighbourOffsets = \
		[
		Vector2(pointsData.step.x, -pointsData.step.y),
		Vector2(pointsData.step.x, 0),
		Vector2(pointsData.step.x, pointsData.step.y),
		Vector2(0, pointsData.step.y)
		]

	var startTime : int
	var retVal := []

	retVal.clear()
	startTime = OS.get_system_time_msecs()
	retVal = CollisionAStarBuilderGd._createConnections(pointsData, neighbourOffsets)
	print( str(OS.get_system_time_msecs() - startTime) + "ms" )
	retVal.clear()
	startTime = OS.get_system_time_msecs()
	retVal = CollisionAStarBuilderGd._createConnections(pointsData, neighbourOffsets)
	print( str(OS.get_system_time_msecs() - startTime) + "ms" )
	retVal.clear()
	startTime = OS.get_system_time_msecs()
	retVal = CollisionAStarBuilderGd._createConnections(pointsData, neighbourOffsets)
	print( str(OS.get_system_time_msecs() - startTime) + "ms" )

	print("")
	retVal.clear()
	startTime = OS.get_system_time_msecs()
	retVal = CollisionAStarBuilderGd._createConnectionsNoIfs(pointsData, neighbourOffsets)
	print( str(OS.get_system_time_msecs() - startTime) + "ms" )
	retVal.clear()
	startTime = OS.get_system_time_msecs()
	retVal = CollisionAStarBuilderGd._createConnectionsNoIfs(pointsData, neighbourOffsets)
	print( str(OS.get_system_time_msecs() - startTime) + "ms" )
	retVal.clear()
	startTime = OS.get_system_time_msecs()
	retVal = CollisionAStarBuilderGd._createConnectionsNoIfs(pointsData, neighbourOffsets)
	print( str(OS.get_system_time_msecs() - startTime) + "ms" )

	return retVal
