extends VBoxContainer

const TypeLineGd = preload("res://AbstractTypeLine.gd")
#const TypeLineScn = preload("res://TypeLine.tscn")

onready var spinAmount                 = $"ObjectAmount/Amount" as SpinBox
onready var typeLines                  = $"Lines" as HBoxContainer


#signal creationTime( type, timeMs, size )
#signal computationTime( type, timeMs, size )
#signal memoryConsumption( type, sta, dyn, size )
#signal objectCountChanged( type, count )


func _init():
	OS.set_window_always_on_top(true)


func _ready():
	for line in typeLines.get_children():
		assert( line is TypeLineGd )
		var ret = line.connect("typeToggled", self, "_onTypeToggled", [line])
		assert(ret == OK)


func _onTypeToggled( toggled : bool, line : TypeLineGd ):
	if toggled:
		line.create(int(spinAmount.value))
	else:
		line.destroy()
