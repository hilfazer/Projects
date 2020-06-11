extends Control

const TypeLineGd = preload("res://TypeLine.gd")

enum Type { Ref, Obj, Res, Int, PoolInt, Nod }

var ints := []
var objs := []
var refs := []
var ress := []
var pints := PoolIntArray()
var nods := []

onready var amount                     = $"ObjectAmount/Amount" as SpinBox

onready var type2line = {
	Type.Int : $"Lines/integer" as TypeLineGd,
	Type.PoolInt : $"Lines/pool integer" as TypeLineGd,
	Type.Ref : $"Lines/reference" as TypeLineGd,
	Type.Res : $"Lines/resource" as TypeLineGd,
	Type.Obj : $"Lines/object" as TypeLineGd,
	Type.Nod : $"Lines/node" as TypeLineGd,
}


signal intsCountChanged( count )
signal poolIntsCountChanged( count )
signal objectsCountChanged( count )
signal referencesCountChanged( count )
signal resourcesCountChanged( count )
signal nodesCountChanged( count )

signal creationTime( type, timeMs, size )
signal computationTime( type, timeMs, size )
signal memoryConsumption( type, sta, dyn )


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
	$"Lines/integer/ButtonType".connect("toggled", self, "_on_ButtonInts_toggled")
# warning-ignore:return_value_discarded
	$"Lines/pool integer/ButtonType".connect("toggled", self, "_on_ButtonPoolInts_toggled")
# warning-ignore:return_value_discarded
	$"Lines/object/ButtonType".connect("toggled", self, "_on_ButtonObjects_toggled")
# warning-ignore:return_value_discarded
	$"Lines/reference/ButtonType".connect("toggled", self, "_on_ButtonReferences_toggled")
# warning-ignore:return_value_discarded
	$"Lines/resource/ButtonType".connect("toggled", self, "_on_ButtonResources_toggled")
# warning-ignore:return_value_discarded
	$"Lines/node/ButtonType".connect("toggled", self, "_on_ButtonNodes_toggled")

# warning-ignore:return_value_discarded
	connect("intsCountChanged", $"Lines/integer/Amount", "set_text" )
# warning-ignore:return_value_discarded
	connect("poolIntsCountChanged", $"Lines/pool integer/Amount", "set_text" )
# warning-ignore:return_value_discarded
	connect("objectsCountChanged", $"Lines/object/Amount", "set_text" )
# warning-ignore:return_value_discarded
	connect("referencesCountChanged", $"Lines/reference/Amount", "set_text" )
# warning-ignore:return_value_discarded
	connect("resourcesCountChanged", $"Lines/resource/Amount", "set_text" )
# warning-ignore:return_value_discarded
	connect("nodesCountChanged", $"Lines/node/Amount", "set_text" )

# warning-ignore:return_value_discarded
	$"Lines/integer/ButtonCompute".connect("pressed", self, "computeInts")
# warning-ignore:return_value_discarded
	$"Lines/pool integer/ButtonCompute".connect("pressed", self, "computePoolInts")
# warning-ignore:return_value_discarded
	$"Lines/reference/ButtonCompute".connect("pressed", self, "computeReferences")
# warning-ignore:return_value_discarded
	$"Lines/resource/ButtonCompute".connect("pressed", self, "computeResources")
# warning-ignore:return_value_discarded
	$"Lines/object/ButtonCompute".connect("pressed", self, "computeObjects")
# warning-ignore:return_value_discarded
	$"Lines/node/ButtonCompute".connect("pressed", self, "computeNodes")


class MyObj extends Object:
	func _init():
		pass


class MyRef extends Reference:
	func _init():
		pass


func _on_ButtonInts_toggled(button_pressed):
	ints = []

	var msecStart = OS.get_ticks_msec()
	if button_pressed:
		ints.resize( int(amount.value) )
		for i in int(amount.value):
			ints[i] = 3

	var msecEnd = OS.get_ticks_msec() - msecStart
	emit_signal("intsCountChanged", str( ints.size() ) )
	emit_signal("creationTime", Type.Int, msecEnd, ints.size() )


func _on_ButtonPoolInts_toggled(button_pressed):
	pints.resize( 0 )

	var msecStart = OS.get_ticks_msec()
	if button_pressed:
		pints.resize( int(amount.value) )
		for i in int(amount.value):
			pints[i] = 3

	var msecEnd = OS.get_ticks_msec() - msecStart
	emit_signal("poolIntsCountChanged", str( pints.size() ) )
	emit_signal("creationTime", Type.PoolInt, msecEnd, pints.size() )


func _on_ButtonObjects_toggled(button_pressed):
	for o in objs:
		o.free()
	objs.resize( 0 )

	var msecStart = OS.get_ticks_msec()
	if button_pressed:
		objs.resize( int(amount.value) )
		for i in int(amount.value):
			objs[i] = MyObj.new()

	var msecEnd = OS.get_ticks_msec() - msecStart
	emit_signal("creationTime", Type.Obj, msecEnd, objs.size() )
	emit_signal("objectsCountChanged", str( objs.size() ) )


func _on_ButtonResources_toggled(button_pressed):
	var memoryStart = _getStaticAndDynamicMemory()
	ress.resize( 0 )

	var msecStart = OS.get_ticks_msec()
	if button_pressed:
		ress.resize( int(amount.value) )
		for i in int(amount.value):
			ress[i] = Resource.new()
	var msecEnd = OS.get_ticks_msec() - msecStart

	var memoryEnd = _getStaticAndDynamicMemory()
	emit_signal("creationTime", Type.Res, msecEnd, refs.size() )
	emit_signal("resourcesCountChanged", str( ress.size() ) )
	emit_signal("memoryConsumption", Type.Res, memoryEnd[0] - memoryStart[0], \
			memoryEnd[1] - memoryStart[1] )


func _on_ButtonReferences_toggled(button_pressed):
	refs.resize( 0 )

	var msecStart = OS.get_ticks_msec()
	if button_pressed:
		refs.resize( int(amount.value) )
		for i in int(amount.value):
			refs[i] = MyRef.new()

	var msecEnd = OS.get_ticks_msec() - msecStart
	emit_signal("creationTime", Type.Ref, msecEnd, refs.size() )
	emit_signal("referencesCountChanged", str( refs.size() ) )


func _on_ButtonNodes_toggled(button_pressed):
	for o in nods:
		o.free()
	nods.resize( 0 )

	var msecStart = OS.get_ticks_msec()
	if button_pressed:
		nods.resize( int(amount.value) )
		for i in int(amount.value):
			nods[i] = Node.new()

	var msecEnd = OS.get_ticks_msec() - msecStart
	emit_signal("creationTime", Type.Nod, msecEnd, nods.size() )
	emit_signal("nodesCountChanged", str( nods.size() ) )


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
