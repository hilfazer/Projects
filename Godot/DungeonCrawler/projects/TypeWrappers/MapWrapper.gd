extends Reference
class_name MapWrapper

var _dict = {}       setget deleted


signal changed( dict )


func deleted(_a):
	assert(false)


func _init( dict = {} ):
	_dict = dict


func reset( dict ):
	if _dict == dict:
		return

	_dict = dict
	emit_signal("changed", _dict )

# doesn't alter values of existing keys
func add( dict ):
	var size = _dict.size()
	for x in dict:
		if not x in _dict:
			_dict[x] = dict[x]

	if _dict.size() > size:
		emit_signal("changed", _dict )

# alters values of existing keys, doesn't add new keys
func replace( dict ):
	var changed = false
	for x in dict:
		if x in _dict and _notEqual( _dict[x], dict[x] ):
			_dict[x] = dict[x]
			changed = true

	if changed:
		emit_signal("changed", _dict )

# alters values of existing keys, can add new keys
func addReplace( dict ):
	var changed = false
	for x in dict:
		if not x in _dict or _notEqual(_dict[x], dict[x]):
			_dict[x] = dict[x]
			changed = true

	if changed:
		emit_signal("changed", _dict )


func remove( array ):
	var size = _dict.size()
	for x in array:
		_dict.erase( x )

	if _dict.size() < size:
		emit_signal("changed", _dict )


func copy() -> MapWrapper:
	return load( get_script().resource_path).new( _dict.duplicate(true) )


func container() -> Dictionary:
	return _dict


static func _notEqual( a, b ):
	return typeof(a) != typeof(b) or a != b
