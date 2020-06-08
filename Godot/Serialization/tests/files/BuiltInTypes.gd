extends Node

var b  := false
var v2 := Vector2()
var r2 := Rect2()
var v3 := Vector3()
var t2 := Transform2D()
var pl := Plane()
var q  := Quat()
var ab := AABB()
var ba := Basis()
var t  := Transform()
var co := Color()
var np := NodePath()


func serialize():
	return [b, v2, r2, v3, t2, pl, q, ab, ba, t, co, np]


func deserialize( a : Array ):
	b = a[0]
	v2 = a[1]
	r2 = a[2]
	v3 = a[3]
	t2 = a[4]
	pl = a[5]
	q = a[6]
	ab = a[7]
	ba = a[8]
	t = a[9]
	co = a[10]
	np = a[11]
