extends Reference

var m_array = []               setget deleted


signal changed( array )


func deleted(_a):
	assert(false)


func _init( array = [] ):
	var uniqueArray = unique(array)
	assert( array == uniqueArray )
	m_array = uniqueArray


func reset( array ):
	if m_array == array:
		return

	var uniqueArray = unique(array)
	assert( array == uniqueArray )
	m_array.resize( uniqueArray.size() )
	for i in range( array.size() ):
		m_array[i] = array[i]
	emit_signal("changed", m_array )


func add( array ):
	var size = m_array.size()
	for x in array:
		if not x in m_array:
			m_array.append( x )

	if m_array.size() > size:
		emit_signal("changed", m_array )


func remove( array ):
	var size = m_array.size()
	for x in array:
		m_array.erase( x )

	if m_array.size() < size:
		emit_signal("changed", m_array )


static func unique( array ):
	var b = []
	for x in array:
		if not x in b:
			b.append( x )
	return b
