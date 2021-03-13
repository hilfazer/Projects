extends VBoxContainer

const TypeLineGd = preload("res://AbstractTypeLine.gd")

onready var spinAmount                 = $"ObjectAmount/Amount" as SpinBox
onready var typeLines                  = $"Lines" as VBoxContainer


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
