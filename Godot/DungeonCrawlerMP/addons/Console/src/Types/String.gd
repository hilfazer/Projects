
extends 'BaseType.gd'


# @var  string
var _value


func _init():
  _name = 'String'
  _type = TYPE_STRING


# @param  Varian  value
func check(value):  # int
  _value = str(value)
  return OK


func get( s : String ):  # string
  return _value
