extends "res://addons/gut/test.gd"

const EPSILON = 0.00001


var orphanCount : int
var childrenNumberBeforeTest : int

# TODO: default directory for files and file counting


func before_each():
	orphanCount = int( Performance.get_monitor( Performance.OBJECT_ORPHAN_NODE_COUNT ) )
	childrenNumberBeforeTest = get_child_count()
	# TODO: count nodes recursively


func after_each():
	assert_eq( orphanCount, Performance.get_monitor( Performance.OBJECT_ORPHAN_NODE_COUNT ), \
			"No new orphan nodes" )
	assert_eq( childrenNumberBeforeTest, get_child_count(), "No new nodes" )
