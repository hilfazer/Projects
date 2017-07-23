extends Node


func createNumberPicture(number):
	assert( number < get_child_count() )
	return get_child(number)
