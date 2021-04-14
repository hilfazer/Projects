tool
extends "./TimeMeasureScene.gd"


func _ready():
	addMeasure(GetNodeString.new(),   "GetNodeString")
	addMeasure(GetNodeNodePath.new(), "GetNodeNodePath")
	addMeasure(GetNodeDollar.new(),   "GetNodeDollar")
	addMeasure(GetNodeCached.new(),   "GetNodeCached")


class BaseWithChild extends MeasureBase:
	var ch
	func setup():
		var child = Node.new()
		child.name = "child1"
		add_child(child)
		var prev = child
		child = Node.new()
		child.name = "child2"
		prev.add_child(child)
		prev = child
		child = Node.new()
		child.name = "child3"
		prev.add_child(child)
		prev = child
		child = Label.new()
		child.name = "child4"
		prev.add_child(child)
		ch = child


	func teardown():
		ch.queue_free()
		ch = null


class GetNodeString extends BaseWithChild:
	func _execute():
		var _a
		for i in loopCount:
			_a = get_node("child1/child2/child3/child4").text


class GetNodeNodePath extends BaseWithChild:
	func _execute():
		var _a
		for i in loopCount:
			_a = get_node(@"child1/child2/child3/child4").text


class GetNodeDollar extends BaseWithChild:
	func _execute():
		var _a
		for i in loopCount:
			_a = $"child1/child2/child3/child4".text


class GetNodeCached extends BaseWithChild:
	func _execute():
		var _a
		for i in loopCount:
			_a = ch.text
