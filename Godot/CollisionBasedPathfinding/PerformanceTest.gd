extends Node


func _ready():
	var astar

	print('testConnectionsAfterPoints')
	astar = AStar.new()
	print( str(testConnectionsAfterPoints( Vector2(200, 200), astar ) ) + "ms" )
	astar = AStar.new()
	print( str(testConnectionsAfterPoints( Vector2(200, 200), astar ) ) + "ms" )
	astar = AStar.new()
	print( str(testConnectionsAfterPoints( Vector2(200, 200), astar ) ) + "ms" )

	print('testPointsWithConnections')
	astar = AStar.new()
	print( str(testPointsWithConnections( Vector2(200, 200), astar ) ) + "ms" )
	astar = AStar.new()
	print( str(testPointsWithConnections( Vector2(200, 200), astar ) ) + "ms" )
	astar = AStar.new()
	print( str(testPointsWithConnections( Vector2(200, 200), astar ) ) + "ms" )


func testConnectionsAfterPoints( size : Vector2, astar : AStar ) -> int:
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


func testPointsWithConnections( size : Vector2, astar : AStar ) -> int:
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
