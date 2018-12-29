extends Node


const SetWrapperGd = preload("res://SetWrapper.gd")

var set = [1,2,3]
var setWrapper = SetWrapperGd.new( set )


func _ready():
	print( set )
	setWrapper.connect("changed", self, "printChanged")

	setWrapper.add( [4] )
	assert( set == [1,2,3,4] )
	setWrapper.remove( [4] )
	setWrapper.remove( [8] )
	setWrapper.add( [7] )
	setWrapper.reset( [4,3,6] )
	assert( set == [4,3,6] )


func printChanged( reference ):
	print( reference )
	