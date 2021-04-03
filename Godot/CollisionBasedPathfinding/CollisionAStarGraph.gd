extends Reference


class Graph extends Reference:
	var astar2d : AStar2D


	func _init( astar_ : AStar2D ):
		astar2d = astar_


	static func create( fullAstar2d : AStar2D, shape : RectangleShape2D, collisionMask : int ) -> Graph:
		# TODO
		return Graph.new( AStar2D.new() )
