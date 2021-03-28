tool
extends "./TimeMeasureScene.gd"


func _ready():
# warning-ignore:return_value_discarded
	addMeasure(GetNodeString.new(),   "GetNodeString")
# warning-ignore:return_value_discarded
	addMeasure(GetNodeNodePath.new(), "GetNodeNodePath")
# warning-ignore:return_value_discarded
	addMeasure(GetNodeDollar.new(),   "GetNodeDollar")
# warning-ignore:return_value_discarded
	addMeasure(GetNodeCached.new(),   "GetNodeCached")


class BaseWithChild extends MeasureBase:
	var ch : Label
	func setup():
		var child = Label.new()
		child.name = "child"
		add_child(child)
		ch = child


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
