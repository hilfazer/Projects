extends Node

const GlobalGd                 = preload("res://GlobalNames.gd")


func deleted(a):
	assert(false)


func _init():
	add_to_group(GlobalGd.Groups.Agents)


func _process( delta ):
	processMovement( delta )


func processMovement( delta ):
	assert(false)


func assignUnits( units ):
	assert(false)


func unassignUnits( units ):
	assert(false)