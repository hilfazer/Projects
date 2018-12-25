extends Node



func _ready():
	var arr = [ Node.new() ]

	arr[0].free()
	pass	# place breakpoint here; crash


#func _ready():
#	arrSquareBracketFree()


#func _ready():
#	var n = Node.new()
#
#	n.free()
#	pass	# place breakpoint here; no crash


func _enter_tree():
	var dic = { 1 : Node.new() }

	dic[1].free()
	pass	# place breakpoint here, crash


#func _enter_tree():
#	arrSquareBracketFree()


#func _enter_tree():
#	var n = Node.new()
#
#	n.free()
#	pass	# place breakpoint here; no crash


func _input(event):
	if event.is_action_pressed("ui_select"):
		arrSquareBracketFree()


#func _input(event):
#	if event.is_action_pressed("ui_select"):
#		var arr = [ Node.new() ]
#
#		arr[0].free()
#		pass	# place breakpoint here, crash


func arrSquareBracketFree():
	var arr = [ Node.new() ]

	arr[0].free()
	pass	# place breakpoint here, crash
