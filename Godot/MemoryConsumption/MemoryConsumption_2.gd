extends VBoxContainer

const TypeLineGd = preload("res://TypeLine.gd")

onready var spinAmount                 = $"ObjectAmount/Amount" as SpinBox



signal creationTime( type, timeMs, size )
signal computationTime( type, timeMs, size )
signal memoryConsumption( type, sta, dyn, size )
signal objectCountChanged( type, count )


func _init():
	OS.set_window_always_on_top(true)




func _getStaticAndDynamicMemory():
	return [
		Performance.get_monitor(Performance.MEMORY_STATIC),
		Performance.get_monitor(Performance.MEMORY_DYNAMIC),
	]
