extends Control


export var repeat : int = 3


func _ready():
	$"Run".text = name


func run():
	print(name)
	for i in range(0, repeat):
		print( str(measure()) + " msec" )
	print("")


func measure() -> int:
	var msec := OS.get_ticks_msec()
	_execute()
	msec = OS.get_ticks_msec() - msec
	return msec


func _execute():
	assert(false)
