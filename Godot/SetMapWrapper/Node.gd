extends Node


const SetWrapperGd = preload("res://SetWrapper.gd")

var setWrapper = SetWrapperGd.new( [1,2,3] )   setget , getSet


func _ready():
	print( setWrapper.m_array )
	setWrapper.connect("changed", self, "printChanged")

	setWrapper.add( [4] )
	assert( setWrapper.m_array == [1,2,3,4] )
	setWrapper.remove( [3] )
	assert( setWrapper.m_array == [1,2,4] )
	setWrapper.remove( [8] )
	assert( setWrapper.m_array == [1,2,4] )
	setWrapper.add( [7] )
	assert( setWrapper.m_array == [1,2,4,7] )
	setWrapper.reset( [4,3,6] )
	assert( setWrapper.m_array == [4,3,6] )


func printChanged( reference ):
	print( reference )
	
	
func getSet():
	return setWrapper.m_array
