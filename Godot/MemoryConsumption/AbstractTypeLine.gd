tool
extends HBoxContainer


var objectCount := 0


signal typeToggled( toggled )


func _ready():
# warning-ignore:return_value_discarded
	$"ButtonType".connect("toggled", self, "_emitTypeToggled")


func _process(_delta):
	$"ButtonType".text = name


func create( count : int ) -> void:
	var err          = OK
	var staticStart  = Performance.get_monitor(Performance.MEMORY_STATIC)
	var dynamicStart = Performance.get_monitor(Performance.MEMORY_DYNAMIC)

	var msec = OS.get_ticks_msec()
	err = _create(count)
	msec = OS.get_ticks_msec() - msec

	if err != OK:
		_destroy()
		return

	_setConstructionTime(msec, count)
	_setObjectCount(count)
	_setMemoryUsage(
		Performance.get_monitor(Performance.MEMORY_STATIC) - staticStart,
		Performance.get_monitor(Performance.MEMORY_DYNAMIC) - dynamicStart,
		count
	)


func compute() -> void:
	var msec = OS.get_ticks_msec()
	_compute()
	msec = OS.get_ticks_msec() - msec
	_setComputationTime(msec, objectCount)


func destroy() -> void:
	_destroy()
	_setObjectCount(0)
	_setMemoryUsage(0, 0, objectCount)


func _compute():
	assert( false )


# warning-ignore:unused_argument
func _create( count : int ) -> int:
	assert(false)
	return ERR_DOES_NOT_EXIST


func _destroy():
	assert( false )


func _setMemoryUsage( sta : int, dyn : int, size : int ):
	var total = sta + dyn if sta + dyn > 0 else 0
	$"MemoryTaken".text = String.humanize_size( total )
	var bytesPerObject = total / float(size) if size != 0 else 0
	$"LinePerObject".text = "%.1f B" % bytesPerObject


func _setComputationTime( timeMs : int, size : int ):
	var message = "computing %s: %s ms"
	$"TimeTaken".text = message % [size, timeMs]


func _setConstructionTime( timeMs : int, size : int ):
	var message = "creating %s: %s ms"
	$"TimeTaken".text = message % [size, timeMs]


func _setObjectCount( count : int ):
	objectCount = count
	$"Amount".text = str( count )


func _emitTypeToggled( toggled : bool ):
	emit_signal("typeToggled", toggled)
