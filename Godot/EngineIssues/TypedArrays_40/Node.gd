extends Node


func _ready():
	var incorrectDeclaration: Array[int] = [1, "6", 3.6, null, "s2", AABB()] # not allowed, good

# this produces "_ready: Class names can only be set for type OBJECT" errors
# i get such typed arrays are not supported
	var objects: Array[Object]
	var nodes2d: Array[Node2D]

	var regularArray :Array= [1.6,2.6] # explicit typing is honoured
	regularArray.append(Plane())
	assert( typeof(regularArray.back()) == TYPE_PLANE )

	var arrint: Array[int] = [1,2]
	arrint.append(['f'])
	arrint.append(null)
	arrint.append([6])
	arrint.append(9)
	assert(arrint.size() == 3)	# only int got appended, good

	var withString = appendString( [4,5] ) # it's treated like a regular array, good
	assert(withString.back() == "d")

	var floatArray :Array = makeFloats()
	print(floatArray)

	var array = makeArray()
	array.append([])
	print(array)
	assert(array.size() == 3)


func appendString( ar: Array ):
	ar.append("d")
	return ar


func makeFloats() -> Array[float]:
	return [.4, .5, 's']	# typed array is not enforced for the return type


func makeArray():
	return [.1,.2] # returns a regular array, good
