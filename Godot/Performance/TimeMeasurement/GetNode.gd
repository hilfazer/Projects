tool
extends "./TimeMeasureScene.gd"


func _ready():
	addMeasure(GetNodeString.new(),   "GetNodeString")
	addMeasure(GetNodeNodePath.new(), "GetNodeNodePath")
	addMeasure(GetNodeDollar.new(),   "GetNodeDollar")
	addMeasure(GetNodeCached.new(),   "GetNodeCached")


class BaseWithChild extends MeasureBase:
	var ch : Label
	func setup():
		var child = Label.new()
		child.name = "child"
		add_child(child)
		ch = child


	func teardown():
		ch.queue_free()
		ch = null


class GetNodeString extends BaseWithChild:
	func _execute():
		var _a
		for i in loopCount:
			_a = get_node("child").text


class GetNodeNodePath extends BaseWithChild:
	func _execute():
		var _a
		for i in loopCount:
			_a = get_node(@"child").text


class GetNodeDollar extends BaseWithChild:
	func _execute():
		var _a
		for i in loopCount:
			_a = $"child".text


class GetNodeCached extends BaseWithChild:
	func _execute():
		var _a
		for i in loopCount:
			_a = ch.text
