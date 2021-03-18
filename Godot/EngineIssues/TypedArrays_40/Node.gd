extends Node


func _ready():
	#var incorrectDeclaration: Array[int] = [1, "6", 3.6, null, "s2", AABB()] # not allowed, good

# this produces "_ready: Class names can only be set for type OBJECT" errors
# i get such typed arrays are not supported
#	var objects: Array[Object]
#	var nodes2d: Array[Node2D]
#
#	var regularArray :Array= [1.6,2.6] # explicit typing is honoured
#	regularArray.append(Plane())
#	assert( typeof(regularArray.back()) == TYPE_PLANE )
#
#	var arrint: Array[int] = [1,2]
#	arrint.append(['f'])
#	arrint.append(null)
#	arrint.append([6])
#	arrint.append(9)
#	assert(arrint.size() == 3)	# only int got appended, good
#
#	var withString = appendString( [4,5] ) # it's treated like a regular array, good
#	assert(withString.back() == "d")

	var floatArray1 = makeFloats1()
	var floatArray2 = makeFloats2()
	var floatArray3 = makeFloats3()
	var floatArray4 = makeFloats4()
	var floatArray5 = makeFloats5()
	floatArray1.append('banana')
	floatArray2.append('banana')
	floatArray3.append('banana')
	floatArray4.append('banana')
	floatArray5.append('banana')

	var array = makeArray()
	array.append([])
	print(array)
	assert(array.size() == 3)


#func makeFloats0() -> Array[float]:
#	return [.3,AABB()]	# not allowed, good

func makeFloats1() -> Array[float]:
	var ar : = [.03]	# inferred as Array[float]
	ar.append(Plane() ) # not allowed, good
	return ar

func makeFloats2() -> Array[float]:
	var ar := []	# regular array
	ar.append(Plane() ) # gets appended
	return ar	# returns a normal array with Plane

func makeFloats3() -> Array[float]:
	var ar = [.03] # untyped variable
	ar.append(Plane() )
	return ar # it'll return because 'ar' currently holds an array

func makeFloats4() -> Array[float]:
	var ar :Array # regular array
	ar.append(Plane() ) # gets appended
	return ar	# returns a normal array with Plane
	
func makeFloats5() -> Array[float]:
	return [2] + ['orange']	# returns a normal array
	

func makeArray():
	return [.1,.2] # returns a regular array, good

func appendString( ar: Array ):
	ar.append("d")
	return ar
