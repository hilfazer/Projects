tool
extends Control


export var repeat : int = 3


func _ready():
	$"Run".text = name


func _process(_delta):
	if Engine.editor_hint:
		$"Run".text = name


func run():
	print("--- started: " + name + " ---")
	for _i in range(0, repeat):
		var time : int = measure()
		print( str(time) + " msec" )
		$"TimeTaken".text = str(time)
	print("--- finished ---")


func measure() -> int:
	var msec := OS.get_ticks_msec()
	_execute()
	msec = OS.get_ticks_msec() - msec
	return msec


func _execute():
	assert(false)
