extends Area2D

var m_bodiesInside = []      setget deleted


func deleted():
	assert(false)



func onEntranceBodyEntered(body):
	m_bodiesInside.append( body )


func onEntranceBodyExited(body):
	var bodyIdx = m_bodiesInside.find(body)
	assert(bodyIdx != -1)
	
	m_bodiesInside.remove(bodyIdx)
