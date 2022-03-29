tool
extends "./TimeMeasureScene.gd"


func _ready():
	addMeasure(Branchful1.new(), "Branchful1")
	addMeasure(Branchless1.new(),   "Branchless1")
	addMeasure(Branchful2.new(), "Branchful2")
	addMeasure(Branchless2.new(),   "Branchless2")


class Branchless1 extends MeasureBase:
	func _execute():
# warning-ignore:unused_variable
		var x = 0
		for i in loopCount:
			x += int(i % 4)


class Branchful1 extends MeasureBase:
	func _execute():
# warning-ignore:unused_variable
		var x = 0
		for i in loopCount:
			if i % 4:
				x += 1


class Branchless2 extends MeasureBase:
	func _execute():
		var arr = [0, 0]
		for i in loopCount:
			arr[i % 2] += 1


class Branchful2 extends MeasureBase:
	func _execute():
		var arr = [0, 0]
		for i in loopCount:
			if i % 2:
				arr[0] += 1
			else:
				arr[1] += 1

