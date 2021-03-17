extends Node


func _ready():
	#var incorrectDeclaration: Array[int] = [1, "6", 3.6, null, "s2", AABB()]

	var objects: Array[Object] = [null, Node.new()]

	var nodes2d: Array[Node2D]= [Node2D.new(), Sprite2D.new(), Node.new()]
	nodes2d.append( Node.new() )

	var regularArray :Array[float]= [1.6,2.6]
	regularArray.append(Plane())


	var arrint: Array[int] = [1,2]
	arrint.append(['f'])
	arrint.append(null)
	arrint.append([6])

	var withString = appendString( [4,5] )
	assert(withString.back() == "d")


func appendString( ar: Array ):
	ar.append("d")
