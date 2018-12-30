extends Node


const SetWrapperGd = preload("res://SetWrapper.gd")
const MapWrapperGd = preload("res://MapWrapper.gd")

var setWrapper = SetWrapperGd.new( [1,2,3] )   setget , getSet
var setChanges = 0

var mapWrapper = MapWrapperGd.new( {1:2, 2:3} )   setget , getMap
var mapChanges = 0


func _ready():
	print( setWrapper.m_array )
	setWrapper.connect("changed", self, "printSetChanged")

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
	assert( setChanges == 4 )
	
	print(mapWrapper.m_dict )
	mapWrapper.connect("changed", self, "printMapChanged")
	
	mapWrapper.add( {'s':1, 8:'e'} )
	assert( mapWrapper.m_dict.hash() == {1:2, 2:3,'s':1, 8:'e'}.hash() )
	mapWrapper.add( {'s':'p', 8:5} )
	assert( mapWrapper.m_dict.hash() == {1:2, 2:3,'s':1, 8:'e'}.hash() )
	mapWrapper.reset( {1:2, 2:3, 3:4} )
	assert( mapWrapper.m_dict.hash() == {1:2, 2:3, 3:4}.hash() )
	mapWrapper.remove( {2:3} )
	assert( mapWrapper.m_dict.hash() == {1:2, 3:4}.hash() )
	mapWrapper.remove( {2:3} )
	assert( mapWrapper.m_dict.hash() == {1:2, 3:4}.hash() )
	mapWrapper.replace( {1:'o', 6:4} )
	assert( mapWrapper.m_dict.hash() == {1:'o', 3:4, 6:4}.hash() )
	assert( mapChanges == 4 )


func printSetChanged( reference ):
	print( reference )
	setChanges += 1
	
func printMapChanged( reference ):
	print( reference )
	mapChanges += 1
	
	
func getSet():
	return setWrapper.m_array

func getMap():
	return mapWrapper.m_dict