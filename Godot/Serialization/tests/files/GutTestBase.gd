extends "res://addons/gut/test.gd"

const EPSILON = 0.00001


var orphanCount : int

# TODO: default directory for files and file counting


func before_each():
	orphanCount = int( Performance.get_monitor( Performance.OBJECT_ORPHAN_NODE_COUNT ) )


func after_each():
	for child in get_children():
		child.free()
	assert( get_child_count() == 0 )

	assert_eq( orphanCount, Performance.get_monitor( Performance.OBJECT_ORPHAN_NODE_COUNT ), \
			"No new orphan nodes" )
