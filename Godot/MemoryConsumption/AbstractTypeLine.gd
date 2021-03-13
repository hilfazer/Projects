extends HBoxContainer


var objectCount := 0


signal typeToggled( toggled )


func _ready():
# warning-ignore:return_value_discarded
	$"ButtonType".connect("toggled", self, "_emitTypeToggled")


func setMemoryUsage( sta : int, dyn : int, size : int ):
	var total = sta + dyn if sta + dyn > 0 else 0
	$"MemoryTaken".text = String.humanize_size( total )
	var bytesPerObject = total / float(size) if size != 0 else 0
	$"LinePerObject".text = "%.1f" % bytesPerObject


func setComputationTime( timeMs : int, size : int ):
	var message = "computing %s: %s msec"
	$"TimeTaken".text = message % [size, timeMs]


func setConstructionTime( timeMs : int, size : int ):
	var message = "creating %s: %s ms"
	$"TimeTaken".text = message % [size, timeMs]


func setObjectCount( count : int ):
	objectCount = count
	$"Amount".text = str( count )


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

	setConstructionTime(msec, count)
	setObjectCount(count)
	setMemoryUsage(
		Performance.get_monitor(Performance.MEMORY_STATIC) - staticStart,
		Performance.get_monitor(Performance.MEMORY_DYNAMIC) - dynamicStart,
		count
	)


func compute() -> void:
	var msec = OS.get_ticks_msec()
	_compute()
	msec = OS.get_ticks_msec() - msec
	setComputationTime(msec, objectCount)


func destroy():
	_destroy()
	setObjectCount(0)
	setMemoryUsage(0, 0, objectCount)


func _compute():
	assert( false )


# warning-ignore:unused_argument
func _create( count : int ) -> int:
	assert(false)
	return ERR_DOES_NOT_EXIST


func _destroy():
	assert( false )

func _emitTypeToggled( toggled : bool ):
	emit_signal("typeToggled", toggled)
