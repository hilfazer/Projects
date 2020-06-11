extends Control

const TypeLineGd = preload("res://TypeLine.gd")

enum Type { Ref, Obj, Res, Int, PoolInt, Nod }

var ints := []
var pints := PoolIntArray()
var refs := []
var ress := []
var objs := []
var nods := []

var type2array = {
	Type.Int : ints,
	# no Type.PoolInt because it's passed by value
	Type.Ref : refs,
	Type.Res : ress,
	Type.Obj : objs,
	Type.Nod : nods,
}

onready var spinAmount                 = $"ObjectAmount/Amount" as SpinBox

onready var type2line = {
	Type.Int : $"Lines/integer" as TypeLineGd,
	Type.PoolInt : $"Lines/poolInt" as TypeLineGd,
	Type.Ref : $"Lines/reference" as TypeLineGd,
	Type.Res : $"Lines/resource" as TypeLineGd,
	Type.Obj : $"Lines/object" as TypeLineGd,
	Type.Nod : $"Lines/node" as TypeLineGd,
}

signal creationTime( type, timeMs, size )
signal computationTime( type, timeMs, size )
signal memoryConsumption( type, sta, dyn )
signal objectCountChanged( type, count )


func _init():
	OS.set_window_always_on_top(true)


func _ready():
# warning-ignore:return_value_discarded
	connect("computationTime", self, "_updateComputationTime")
# warning-ignore:return_value_discarded
	connect("creationTime", self, "_updateCreationTime")
# warning-ignore:return_value_discarded
	connect("memoryConsumption", self, "_updateMemoryConsumption")
# warning-ignore:return_value_discarded
	connect("objectCountChanged", self, "_updateObjectCount")

# warning-ignore:return_value_discarded
	$"Lines/integer/ButtonType".connect("toggled", self, "_signalObjectsChange", [Type.Int])
# warning-ignore:return_value_discarded
	$"Lines/poolInt/ButtonType".connect("toggled", self, "_signalObjectsChange", [Type.PoolInt])
# warning-ignore:return_value_discarded
	$"Lines/object/ButtonType".connect("toggled", self, "_signalObjectsChange", [Type.Obj])
# warning-ignore:return_value_discarded
	$"Lines/reference/ButtonType".connect("toggled", self, "_signalObjectsChange", [Type.Ref])
# warning-ignore:return_value_discarded
	$"Lines/resource/ButtonType".connect("toggled", self, "_signalObjectsChange", [Type.Res])
# warning-ignore:return_value_discarded
	$"Lines/node/ButtonType".connect("toggled", self, "_signalObjectsChange", [Type.Nod])

# warning-ignore:return_value_discarded
	$"Lines/integer/ButtonCompute".connect("pressed", self, "computeInts")
# warning-ignore:return_value_discarded
	$"Lines/poolInt/ButtonCompute".connect("pressed", self, "computePoolInts")
# warning-ignore:return_value_discarded
	$"Lines/reference/ButtonCompute".connect("pressed", self, "computeReferences")
# warning-ignore:return_value_discarded
	$"Lines/resource/ButtonCompute".connect("pressed", self, "computeResources")
# warning-ignore:return_value_discarded
	$"Lines/object/ButtonCompute".connect("pressed", self, "computeObjects")
# warning-ignore:return_value_discarded
	$"Lines/node/ButtonCompute".connect("pressed", self, "computeNodes")


func _signalObjectsChange( create : bool, type : int ):
	var memoryStart = _getStaticAndDynamicMemory()
	_clearObjects( type )
	var msecElapsed = _addObjects( type, spinAmount.value if create else 0 )
	var memoryEnd = _getStaticAndDynamicMemory()


	emit_signal("creationTime", type, msecElapsed, _getArraySize(type) )
	emit_signal("objectCountChanged", type, _getArraySize(type) )
	emit_signal("memoryConsumption", type, memoryEnd[0] - memoryStart[0], \
			memoryEnd[1] - memoryStart[1] )


func _clearObjects( type : int ) -> void:
	match type:
		Type.Obj, Type.Nod:
			for obj in type2array[type]:
				obj.free()
			objs.resize(0)

	if type == Type.PoolInt:
		pints.resize(0)
	else:
		type2array[type].resize(0)


func _addObjects( type : int, amount : int ) -> int:
	var msecStart = OS.get_ticks_msec()

	if not type in [Type.PoolInt]:
		type2array[type].resize( amount )

	match type:
		Type.Int:
			for i in int( amount ):
				ints[i] = 3
		Type.PoolInt:
			pints.resize( amount )
			for i in int( amount ):
				pints[i] = 3
		Type.Obj:
			for i in int( amount ):
				objs[i] = MyObj.new()
		Type.Nod:
			for i in int( amount ):
				nods[i] = Node.new()
		Type.Ref:
			for i in int( amount ):
				refs[i] = Reference.new()
		Type.Res:
			for i in int( amount ):
				ress[i] = Resource.new()

	var msecEnd = OS.get_ticks_msec() - msecStart
	return msecEnd


func _getArraySize( type : int ) -> int:
	if type == Type.PoolInt:
		return pints.size()
	else:
		return type2array[type].size()


func computeInts():
	var msecStart = OS.get_ticks_msec()

	var _sum := 0
	for i in range(ints.size()):
		_sum += ints[i]

	var msecEnd = OS.get_ticks_msec() - msecStart
	emit_signal("computationTime", Type.Int, msecEnd, ints.size() )


func computePoolInts():
	var msecStart = OS.get_ticks_msec()

	var _sum := 0
	for i in range(pints.size()):
		_sum += pints[i]

	var msecEnd = OS.get_ticks_msec() - msecStart
	emit_signal("computationTime", Type.PoolInt, msecEnd, pints.size() )


func computeReferences():
	var msecStart = OS.get_ticks_msec()

	var _ref : Reference
	for i in range(refs.size()):
		_ref = refs[i]

	var msecEnd = OS.get_ticks_msec() - msecStart
	emit_signal("computationTime", Type.Ref, msecEnd, refs.size() )


func computeResources():
	var msecStart = OS.get_ticks_msec()

	var _ref : Resource
	for i in range(ress.size()):
		_ref = ress[i]

	var msecEnd = OS.get_ticks_msec() - msecStart
	emit_signal("computationTime", Type.Res, msecEnd, ress.size() )


func computeObjects():
	var msecStart = OS.get_ticks_msec()

	var _ref : Object
	for i in range(objs.size()):
		_ref = objs[i]

	var msecEnd = OS.get_ticks_msec() - msecStart
	emit_signal("computationTime", Type.Obj, msecEnd, objs.size() )


func computeNodes():
	var msecStart = OS.get_ticks_msec()

	var _ref : Node
	for i in range(nods.size()):
		_ref = nods[i]

	var msecEnd = OS.get_ticks_msec() - msecStart
	emit_signal("computationTime", Type.Nod, msecEnd, nods.size() )


func _getStaticAndDynamicMemory():
	return [
		Performance.get_monitor(Performance.MEMORY_STATIC),
		Performance.get_monitor(Performance.MEMORY_DYNAMIC),
	]


func _updateComputationTime( type : int, timeMs : int, size : int ):
	type2line[type].setComputationTime( timeMs, size )


func _updateCreationTime( type : int, timeMs : int, size : int ):
	type2line[type].setConstructionTime( timeMs, size )


func _updateMemoryConsumption( type, sta, dyn ):
	type2line[type].setMemoryUsage( sta, dyn )


func _updateObjectCount( type : int, count : int ):
	type2line[type].setObjectCount( count )



class MyObj extends Object:
	func _init():
		pass


class MyRef extends Reference:
	func _init():
		pass

