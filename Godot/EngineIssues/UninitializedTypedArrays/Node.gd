extends Node

var arrayMember1 : Array
var arrayMember2 : Array

func _ready():
	var arrayFunction1 : Array
	var arrayFunction2 : Array

	arrayFunction1.append(1)
	arrayFunction2.append(1)
	print(arrayFunction2)

	arrayMember1.append(1)
	arrayMember2.append(1)
	print(arrayMember1)

	var arrayClass1 = Class.new()
	var arrayClass2 = Class.new()
	print(arrayClass2.array)

	assert(arrayFunction1.size() == 1)
	assert(arrayMember1.size() == 1)
	assert(arrayClass2.size() == 1)


class Class extends Object:
	var array : Array
	func _init():
		array.append(1)
