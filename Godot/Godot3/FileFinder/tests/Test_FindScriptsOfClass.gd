extends "res://tests/GutTestBase.gd"

const FileFinderGd = preload("res://FileFinder.gd")


func test_findNodeSubclasses():
	var scripts := PoolStringArray()
	scripts.append("res://tests/files/NodeSubclass.gd")
	var nodeSubclasses = FileFinderGd.findScriptsOfClass(scripts, Node)
	assert_eq(nodeSubclasses.size(), 1)

	var node2Dsubclasses = FileFinderGd.findScriptsOfClass(scripts, Node2D)
	assert_eq(node2Dsubclasses.size(), 0)
