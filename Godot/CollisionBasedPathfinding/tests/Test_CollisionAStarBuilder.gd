extends "res://tests/GutTestBase.gd"

const AStarBuilderGd = preload("res://CollisionAStarBuilder.gd")


func test_initializeIncorrectData():
	var builder : AStarBuilderGd = autofree( AStarBuilderGd.new() )
	var result : int

	# no area
	result = builder.initialize( Vector2(16,16), Rect2() )
	assert_eq(result, ERR_CANT_CREATE)

	# incorrect cell size
	result = builder.initialize( Vector2(), Rect2(10,20,30,30), Vector2(20,10), true )
	assert_eq(result, ERR_CANT_CREATE)

	# negative offset
	result = builder.initialize( Vector2(16,24), Rect2(-4,-6, 50, 52), Vector2(0,-9), true )
	assert_eq(result, ERR_CANT_CREATE)
	result = builder.initialize( Vector2(10,24), Rect2(-4,0, 509, 71), Vector2(-5,12), false )
	assert_eq(result, ERR_CANT_CREATE)

	# offset too large
	result = builder.initialize( Vector2(18,22), Rect2(-4,-6, 50, 52), Vector2(0,77), true )
	assert_eq(result, ERR_CANT_CREATE)
	result = builder.initialize( Vector2(16,16), Rect2(-4,0, 509, 71), Vector2(31,12), false )
	assert_eq(result, ERR_CANT_CREATE)


func test_initialize():
	var builder : AStarBuilderGd = autofree( AStarBuilderGd.new() )
	var result : int
	result = builder.initialize( Vector2(16,24), Rect2(-4,-6, 50, 52), Vector2(12,12), false )
	assert_eq(result, OK)


func test_alreadyInitialized():
	var builder : AStarBuilderGd = autofree( AStarBuilderGd.new() )
	var result : int

	result = builder.initialize( Vector2(16,24), Rect2(-4,-6, 44, 72), Vector2(0,12), false )
	assert_eq(result, OK)
	result = builder.initialize( Vector2(10,24), Rect2(-4,-6, 150, 58), Vector2(5,12), false )
	assert_eq(result, ERR_ALREADY_EXISTS)


func test_createGraphFailure():
	var builder : AStarBuilderGd = autofree( AStarBuilderGd.new() )
	var id : int

	id = builder.createGraph( RectangleShape2D.new() )
	assert_lt(id, 1)


func test_createGraph():

	var builder : AStarBuilderGd = autofree( AStarBuilderGd.new() )
	var result = builder.initialize( Vector2(16, 16), Rect2(0, 0, 100, 100) )
	assert(result == OK)
	var graphId : int = builder.createGraph( RectangleShape2D.new() )
	assert_gt( graphId, 0 )
	assert_eq( builder._previousGraphId, graphId )
	assert_has( builder._graphs, graphId )

	var astar : AStar2D = builder.getAStar2D(graphId)
	assert_not_null(astar)
	assert_eq( astar.get_point_count(), builder._astar.get_point_count() )


