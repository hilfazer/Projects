extends Reference


var name : String                      setget deleted
var icon : Texture                     setget deleted


func deleted(_a):
	assert(false)


func _init( name_ : String, icon_ : Texture ):
	name = name_
	icon = icon_
