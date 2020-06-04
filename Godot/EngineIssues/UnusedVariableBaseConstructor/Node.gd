extends Node


func _ready():
	var d = Derived.new(2)


class Base:
	func _init(a):
		aa = a

	var aa


class Derived extends Base:
	func _init(a).(a):
		pass
