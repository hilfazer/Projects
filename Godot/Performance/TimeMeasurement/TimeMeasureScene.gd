tool
extends Control


export(PackedScene) onready var LineScn
export var loopCount := 5_000_000 setget setLoopCount
export var repeat := 3

var measureNodes := []


func _process(_delta):
	$"VBoxContainer/Label".text = name


func addMeasure(measureNode : MeasureBase, nodeName : String) -> void:
	if nameExists(nodeName):
		print("Node name %s already exists" % [nodeName])
		return

	measureNode.name = nodeName
	add_child(measureNode)
	measureNodes.append(measureNode)
	measureNode.loopCount = loopCount

	var line = LineScn.instance()
	$"VBoxContainer".add_child(line)
	line.get_node("Run").text = measureNode.name
	line.get_node("Run").connect("pressed", self, "run", [measureNode, line, repeat])

	return


# warning-ignore:shadowed_variable
static func run(measureNode : MeasureBase, lineScene, repeat : int):
	measureNode.setup()

	print("--- started: " + measureNode.name + " ---")
	for _i in range(0, repeat):
		var time : int = measureNode.measureTime()
		print( str(time) + " msec" )
		lineScene.get_node(@"TimeTaken").text = str(time)

	measureNode.teardown()
	print("--- finished ---")


func setLoopCount(count : int):
	loopCount = count

	for node in measureNodes:
		node.loopCount = count


func nameExists(nodename : String) -> bool:
	for node in measureNodes:
		if nodename == node.name:
			return true

	return false
