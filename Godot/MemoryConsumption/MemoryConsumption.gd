extends Control


enum Type { Ref, Obj, Res, Int, PoolInt, Nod }

var ints := []
var objs := []
var refs := []
var ress := []
var pints := PoolIntArray()
var nods := []

onready var amount = $"ObjectAmount" as SpinBox


signal intsCountChanged( count )
signal poolIntsCountChanged( count )
signal objectsCountChanged( count )
signal referencesCountChanged( count )
signal resourcesCountChanged( count )
signal nodesCountChanged( count )


func _init():
	OS.set_window_always_on_top(true)


func _ready():
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


func create( type : int ):
	match type:
		Type.Ref:
			return Reference.new()
		Type.Res:
			return Resource.new()
		Type.Obj:
			return MyObj.new()
		Type.Int:
			return 3
		Type.Nod:
			return Node.new()


class MyObj extends Object:
	func _init():
		pass


class MyRef extends Reference:
	func _init():
		pass


func _on_ButtonInts_toggled(button_pressed):
	if button_pressed:
		ints.resize( int(amount.value) )
		for i in int(amount.value):
			ints[i] = 3
	else:
		ints = []
	emit_signal("intsCountChanged", str( ints.size() ) )


func _on_ButtonPoolInts_toggled(button_pressed):
	if button_pressed:
		pints.resize( int(amount.value) )
		for i in int(amount.value):
			pints[i] = 3
	else:
		pints.resize( 0 )
	emit_signal("poolIntsCountChanged", str( pints.size() ) )


func _on_ButtonObjects_toggled(button_pressed):
	if button_pressed:
		objs.resize( int(amount.value) )  # amount.value was 100000
		for i in int(amount.value):
			objs[i] = MyObj.new()
	else:
		for o in objs:
			o.free()
		objs.resize( 0 )
	emit_signal("objectsCountChanged", str( objs.size() ) )


func _on_ButtonResources_toggled(button_pressed):
	if button_pressed:
		ress.resize( int(amount.value) )
		for i in int(amount.value):
			ress[i] = Resource.new()
	else:
		ress.resize( 0 )
	emit_signal("resourcesCountChanged", str( ress.size() ) )


func _on_ButtonReferences_toggled(button_pressed):
	if button_pressed:
		refs.resize( int(amount.value) )
		for i in int(amount.value):
			refs[i] = MyRef.new()
	else:
		refs.resize( 0 )
	emit_signal("referencesCountChanged", str( refs.size() ) )


func _on_ButtonNodes_toggled(button_pressed):
	if button_pressed:
		nods.resize( int(amount.value) )
		for i in int(amount.value):
			nods[i] = Node.new()
	else:
		for o in nods:
			o.free()
		nods.resize( 0 )
	emit_signal("nodesCountChanged", str( nods.size() ) )


func _on_ButtonAddInts_pressed():
	var msecStart = OS.get_ticks_msec()

	var _sum := 0
	for i in range(ints.size()):
		_sum += ints[i]


	print( "adding %s ints took %s msec" % [ints.size(), OS.get_ticks_msec() - msecStart] )


func _on_ButtonAddPoolInts_pressed():
	var msecStart = OS.get_ticks_msec()

	var _sum := 0
	for i in range(pints.size()):
		_sum += pints[i]

	print( "adding %s pool ints took %s msec" % [pints.size(), OS.get_ticks_msec() - msecStart] )
