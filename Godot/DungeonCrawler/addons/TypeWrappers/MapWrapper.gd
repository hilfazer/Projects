extends Reference

var m_dict = {}       setget deleted


signal changed( dict )


func deleted(_a):
	assert(false)


func _init( dict = {} ):
	m_dict = dict


func reset( dict ):
	if m_dict == dict:
		return

	m_dict = dict
	emit_signal("changed", m_dict )

# doesn't alter values of existing keys
func add( dict ):
	var size = m_dict.size()
	for x in dict:
		if not x in m_dict:
			m_dict[x] = dict[x]

	if m_dict.size() > size:
		emit_signal("changed", m_dict )

# alters values of existing keys, can add new keys
func replace( dict ):
	var changed = false
	for x in dict:
		if not x in m_dict or _notEqual(m_dict[x], dict[x]):
			m_dict[x] = dict[x]
			changed = true

	if changed:
		emit_signal("changed", m_dict )


func remove( array ):
	var size = m_dict.size()
	for x in array:
		m_dict.erase( x )

	if m_dict.size() < size:
		emit_signal("changed", m_dict )


static func _notEqual( a, b ):
	return typeof(a) != typeof(b) or a != b
