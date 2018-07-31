extends Area2D

var bodiesInside = []


func deleted():
	assert(false)



func onEntranceBodyEntered(body):
	bodiesInside.append( body )


func onEntranceBodyExited(body):
	var bodyIdx = bodiesInside.find(body)
	assert(bodyIdx != -1)
	
	bodiesInside.remove(bodyIdx)
