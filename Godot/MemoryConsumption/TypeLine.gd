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
