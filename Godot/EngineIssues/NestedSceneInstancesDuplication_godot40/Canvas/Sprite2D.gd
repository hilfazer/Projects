extends Sprite2D


@export var variable = 9

var my_array: Array[int] = [1, "6", 3.6, null, "s2", AABB()]
var arrint: Array[int] = [1,2]

var regularArray :Array= [1.6,2.6]



func _ready():
	var _localIntArray: Array[int] = [1, "6", 3.6, null, "s2", AABB()]
	
	regularArray.append(Plane())
	takeArray( [4,5] )

	var arrint2d : Array[Array[int]] = [[]]

	arrint2d[0].append(0)	# works, good
	arrint2d[0].append('re')	# works, bad
	arrint2d.append(2)	# runtime error, good
	arrint2d.append([5.5])	# works, bad
#	arrint2d[0] = [null] # parsing error, it's expecting a value of type [int], good!

	arrint.append(['f'])
	arrint.append(null)
	arrint.append([6])


	pass


func takeArray( ar: Array ):
	ar.append("d")
	assert(ar.back() == "d")
	pass
