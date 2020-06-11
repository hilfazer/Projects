extends HBoxContainer


func setMemoryUsage( dyn : int, sta : int ):
	pass


func setComputationTime( timeMs : int, size : int ):
	var message = "computing %s: %s msec"
	$"TimeTaken".text = message % [size, timeMs]


func setConstructionTime( timeMs : int, size : int ):
	var message = "creating %s: %s msec"
	$"TimeTaken".text = message % [size, timeMs]
