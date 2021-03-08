extends HBoxContainer


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
	$"Amount".text = str( count )


# warning-ignore:unused_argument
func create( count : int ) -> int:
	var msecStart = OS.get_ticks_msec()
	_create(count)
	return OS.get_ticks_msec() - msecStart


func destroy():
	assert( false )


func compute() -> int:
	var msecStart = OS.get_ticks_msec()
	_compute()
	return OS.get_ticks_msec() - msecStart


func _compute():
	assert( false )


func _create( count : int ):
	assert(false)
