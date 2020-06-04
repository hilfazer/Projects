extends VBoxContainer

# memory leaks in 3.2.2 beta 2, no leak in 3.2.1
# leaks happens when creating custom Object derived class or a Node
# no leak when creating References or Resources

# check 'static memory' in Debugger > Monitors

var objects := []


func _on_Button_pressed():
	objects.resize( $"SpinBox".value )
	for i in $"SpinBox".value:
		objects[i] = MyObject.new()

	for i in $"SpinBox".value:
		objects[i].free()

	objects.resize(0)


class MyObject extends Object:
	func _init():
		pass
